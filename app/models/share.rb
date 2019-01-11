class Share < ApplicationRecord
  has_many :feeds, as: :actionable
	acts_as_commentable
	validates_presence_of	:article_id, :user_id
	has_many	:opinions
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

	def comment_count
		self.root_comments.size
	end

	def agree_count
		self.agrees.size
	end

	def disagree_count
		self.disagrees.size
	end

	def json_data(is_ratings=true)
		{
			id: self.id,
			isRatings: is_ratings,
			date: self.created_at.strftime("%e %b"),
			commentsLoaded: false,
			opinionsLoaded: false,
			commentCount: self.comment_count,
			agreeCount: self.agree_count,
			disagreeCount: self.disagree_count,
			post: self.post,
			showComments: false,
			showAgrees: false,
			showDisagrees: false,
			commentShowLimit: Comment.show_limit,
			agreeShowLimit: Opinion.show_limit,
			disagreeShowLimit: Opinion.show_limit
		}
	end

	def has_ratings?
		(self.rating_well_written > 0) || (self.rating_valid_points > 0) || (self.rating_agree > 0)
	end
end
