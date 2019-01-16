class Opinion < ApplicationRecord
  has_many :feeds, as: :actionable
  has_many :notifications, as: :eventable
	belongs_to	:user
	belongs_to	:share
	before_create	:update_feed
	after_destroy	:delete_feed_and_notification
	# after_create :create_notification

	def update_feed
		self.feeds.build({user_id: self.user_id})
	end

  # def create_notification
  #   self.notifications.create({
  #     user_id: self.share.user_id,
  #     specific_type: self.decision,
  #     body: "<b>#{self.user.display_name}</b> #{self.decision}d with your post",
  #     feed_id: self.feeds.first.id
  #   })
  # end

	def delete_feed_and_notification
		self.feeds.destroy_all
		self.notifications.destroy_all
	end

	def self.show_limit
		10
	end
end
