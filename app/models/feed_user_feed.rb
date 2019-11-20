class FeedUserFeed < ApplicationRecord
	def self.primary_key
		'feed_id'
	end
	def self.table_name
		'feed_users_feeds'
	end

end
