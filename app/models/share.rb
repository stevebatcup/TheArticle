class Share < ApplicationRecord
  has_many :feeds, as: :actionable
	has_many :concern_reports, as: :sourceable
	acts_as_commentable
	validates_presence_of	:article_id, :user_id
	has_many	:opinions, dependent: :destroy
	has_many	:opinion_groups, dependent: :destroy
	belongs_to	:user
	belongs_to	:article

	before_save :percentagise_ratings
	after_create	:notify_mentioned_users
	after_create	:update_feeds
	after_save	:recalculate_article_ratings
	after_save	:set_user_share_counts
	after_destroy	:delete_associated_data

	def notify_mentioned_users
		if self.post.length > 0
			post_html =  Nokogiri::HTML.fragment(self.post)
			post_html.css('span.mentioned_user').each do |span|
				other_user_id = span.attributes["data-user"].value.to_i
				Notification.create({
					user_id: other_user_id,
					eventable_id: self.user.id,
					eventable_type: "Mentioner",
					share_id: self.id,
					body: "<a href='/profile/#{self.user.slug}'><b>#{self.user.display_name}</b> <span class='text-muted'>#{self.user.username}</span></a> mentioned you in a post",
					created_at: Time.now,
					updated_at: Time.now
				})
			end
		end
	end

	def update_feeds
		feed = self.feeds.create({user_id: self.user_id})
		self.user.followers.each do |follower|
			user_feed_item = FeedUser.new({
				user_id: follower.id,
				action_type: 'share',
				source_id: self.id,
				created_at: Time.now,
				updated_at: Time.now
			})
			user_feed_item.feeds << feed
			user_feed_item.save
		end
	end

	def percentagise_ratings
		[:well_written, :valid_points, :agree].each do |rating_cat|
			current = self.send("rating_#{rating_cat}")
			case current
			when 0
				self["rating_#{rating_cat}"] = nil
			when 1
				self["rating_#{rating_cat}"] = 0
			when 2
				self["rating_#{rating_cat}"] = 25
			when 3
				self["rating_#{rating_cat}"] = 50
			when 4
				self["rating_#{rating_cat}"] = 75
			when 5
				self["rating_#{rating_cat}"] = 100
			end
		end
	end

	def recalculate_article_ratings
		self.article.recalculate_ratings_caches
	end

	def delete_associated_data
		self.feeds.destroy_all
		self.opinions.destroy_all
		self.concern_reports.destroy_all
		recalculate_article_ratings
	end

	def current_user_can_interact(current_user)
		if current_user == self.user
			'yes'
		else
			if current_user.is_followed_by(self.user)
				if Follow.users_are_connected(current_user, self.user)
					'yes'
				else
					'not_following'
				end
			else
				if self.user.is_followed_by(current_user)
					'not_followed'
				else
					false
				end
			end
		end
	end

	def agrees
		self.opinions.where(decision: :agree)
	end

	def disagrees
		self.opinions.where(decision: :disagree)
	end

	def self.share_onlys
		# where(rating_well_written: 0, rating_valid_points: 0, rating_agree: 0)
		where(share_type: 'share')
	end

	def self.ratings
		# where('rating_well_written > 0 OR rating_valid_points > 0 OR rating_agree > 0')
		where(share_type: 'rating')
	end

	def comment_count(current_user=nil)
		if current_user
			commentsOk = []
			self.root_comments.each do |root_comment|
				unless  current_user.is_comment_disallowed?(root_comment)
					commentsOk << root_comment
				end
			end
			commentsOk.size
		else
			self.root_comments.size
		end
	end

	def agree_count
		self.agrees.size
	end

	def disagree_count
		self.disagrees.size
	end

	def has_ratings?
		# (self.rating_well_written > 0) || (self.rating_valid_points > 0) || (self.rating_agree > 0)
		self.share_type == 'rating'
	end

	def self.create_or_replace(article, current_user, post, rating_well_written, rating_valid_points, rating_agree)
		if rating = current_user.existing_article_rating(article)
			rating.update_attributes(
				post: post,
				rating_well_written: rating_well_written,
				rating_valid_points: rating_valid_points,
				rating_agree: rating_agree
			)
		else
			self.create({
				user_id: current_user.id,
				article_id: article.id,
				post: post,
				rating_well_written: rating_well_written,
				rating_valid_points: rating_valid_points,
				rating_agree: rating_agree
			})
		end
	end

	def self.determine_share_type(params)
		if params[:rating_well_written].to_i > 0 || params[:rating_valid_points].to_i > 0 || params[:rating_agree].to_i > 0
			'rating'
		else
			'share'
		end
	end

	def set_user_share_counts
		self.user.set_share_counts
	end
end
