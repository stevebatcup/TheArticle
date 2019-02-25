class Opinion < ApplicationRecord
  has_many :feeds, as: :actionable
  has_many :notifications, as: :eventable
	belongs_to	:user
	belongs_to	:share
	belongs_to	:opinion_group, optional: true
	after_create	:update_feeds
	after_create	:create_notification
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

	def create_notification
		sharer = User.find(self.share.user_id)
		sharer_interaction_mute_share_ids = sharer.interaction_mutes.map(&:share_id) # maybe the sharer does not want to hear about this?
		unless sharer_interaction_mute_share_ids.include?(self.share_id)
			notification = Notification.find_or_create_by({
			  eventable_type: 'Opinion',
			  share_id: self.share_id,
			  user_id: self.share.user_id,
			  feed_id: nil
			})
			notification.specific_type = self.decision
			notification.eventable_id = self.id
			notification.feeds << self.feeds.first
			notification.body = ApplicationController.helpers.group_user_opinion_feed_item(notification, true)
			notification.save
		end
	end

	def delete_feed_and_notification
		self.feeds.destroy_all
	end

	def self.show_limit
		10
	end
end
