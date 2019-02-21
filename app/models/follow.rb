class Follow < ApplicationRecord
  has_many :feeds, as: :actionable
	belongs_to	:user
	belongs_to :followed, :class_name => "User"
	belongs_to	:follow_group, optional: true
	after_create	:update_feed
	after_destroy	:delete_feed

	def update_feed
		feed = self.feeds.build({user_id: self.user_id})
		self.user.followers.each do |follower|
			unless user_feed_item = FeedUser.find_by(user_id: follower.id, action_type: 'follow', source_id: self.followed_id)
				user_feed_item = FeedUser.new({
					user_id: follower.id,
					action_type: 'follow',
					source_id: self.followed_id
				})
			end
			user_feed_item.feeds << feed
			user_feed_item.save
		end
	end

	def delete_feed
		self.feeds.destroy_all
	end

	def self.users_are_connected(current_user, other_user)
		if current_user == other_user
			true
		else
			current_user.is_followed_by(other_user) && other_user.is_followed_by(current_user)
		end
	end

	def self.both_directions_for_user(user)
		where(user_id: user.id).or(where(followed_id: user.id))
	end
end