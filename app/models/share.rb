class Share < ApplicationRecord
  has_many :feeds, as: :actionable
	has_many :concern_reports, as: :sourceable
	acts_as_commentable
	validates_presence_of	:article_id, :user_id
	has_many	:opinions, dependent: :destroy
	has_many	:opinion_groups, dependent: :destroy
	belongs_to	:user
	belongs_to	:article
	before_create	:update_feed

	def update_feed
		self.feeds.build({user_id: self.user_id})
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
		where(rating_well_written: 0, rating_valid_points: 0, rating_agree: 0)
	end

	def self.ratings
		where('rating_well_written > 0 OR rating_valid_points > 0 OR rating_agree > 0')
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
		(self.rating_well_written > 0) || (self.rating_valid_points > 0) || (self.rating_agree > 0)
	end
end
