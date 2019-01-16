class Opinion < ApplicationRecord
  has_many :feeds, as: :actionable
  has_many :notifications, as: :eventable
	belongs_to	:user
	belongs_to	:share
	belongs_to	:opinion_group, optional: true
	before_create	:update_feed
	after_destroy	:delete_feed_and_notification

	def update_feed
		self.feeds.build({user_id: self.user_id})
	end

	def delete_feed_and_notification
		self.feeds.destroy_all
		self.notifications.destroy_all
	end

	def self.show_limit
		10
	end
end
