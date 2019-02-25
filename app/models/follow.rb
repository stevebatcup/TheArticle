class Follow < ApplicationRecord
  has_many :feeds, as: :actionable
	belongs_to	:user
	belongs_to :followed, :class_name => "User"
	belongs_to	:follow_group, optional: true
	after_create	:update_feed
	after_create	:create_notification
	after_destroy	:delete_feed_and_regenerate_notification

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

	def create_notification
		notification = Notification.where(eventable_type: 'Follow')
										.where(user_id: self.followed_id)
										.where("DATE(created_at) = CURDATE()")
										.first()
		if notification.nil?
			notification = Notification.new({
				eventable_type: 'Follow',
				user_id: self.followed_id,
				created_at: Time.now
			})
		end
		notification.eventable_id = self.id
		notification.feeds << self.feeds.first
		notification.body = ApplicationController.helpers.group_user_follow_feed_item(notification, self.user, true)
		notification.save
	end

	def delete_feed_and_regenerate_notification
		self.feeds.destroy_all
		if notification = Notification.where(eventable_type: 'Follow')
										.where(user_id: self.followed_id)
										.where("DATE(created_at) = CURDATE()")
										.first()
			if notification.feeds.any?
				new_body = ApplicationController.helpers.group_user_follow_feed_item(notification, self.user, true)
				notification.update_attribute(:body, new_body)
			else
				notification.destroy
			end
		end
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