class Categorisation < ApplicationRecord
  has_many :feeds, as: :actionable
  has_many :notifications, as: :eventable
	belongs_to	:article
	belongs_to	:exchange
	before_create	:update_feeds
	after_destroy	:delete_feed_and_notification
	after_create	:create_notification

	def update_feeds
		self.exchange.users.each do |user|
			self.feeds.build({user_id: user.id})
		end
	end

  def create_notification
    self.exchange.users.each do |user|
	    self.notifications.create({
	      user_id: user.id,
	      specific_type: nil,
	      body: "An article has been added to the <b>#{self.exchange.name}</b> exchange",
	      feed_id: nil
	    })
	  end
  end

	def delete_feed_and_notification
		self.feeds.destroy_all
		self.notifications.destroy_all
	end

	def self.table_name
		'articles_exchanges'
	end
end