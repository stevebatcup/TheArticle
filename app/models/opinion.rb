class Opinion < ApplicationRecord
  has_many :feeds, as: :actionable
  has_many :notifications, as: :eventable
	belongs_to	:user
	belongs_to	:share
	belongs_to	:opinion_group, optional: true
	after_create	:update_feeds
	after_destroy	:delete_feed_and_notification

	def update_feeds
		feed = self.feeds.create({user_id: self.user_id})
		self.user.followers.each do |follower|
			unless user_feed_item = FeedUser.find_by(user_id: follower.id, action_type: 'opinion', source_id: self.share_id)
				user_feed_item = FeedUser.new({
					user_id: follower.id,
					action_type: 'opinion',
					source_id: self.share_id
				})
			end
			user_feed_item.feeds << feed
			user_feed_item.save
		end
	end

	def delete_feed_and_notification
		self.feeds.destroy_all
		self.notifications.destroy_all
	end

	def self.show_limit
		10
	end
end
