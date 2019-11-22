class FeedNotification < ApplicationRecord
	def self.primary_key
		'feed_id'
	end
	def self.table_name
		'feeds_notifications'
	end
end
