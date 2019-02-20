class Subscription < ApplicationRecord
  has_many :feeds, as: :actionable
	belongs_to	:user
	belongs_to	:exchange
	after_create	:update_feed
	after_destroy	:delete_feed

	def update_feed
		feed = self.feeds.build({user_id: self.user_id})
		self.user.followers.each do |follower|
			unless user_feed_item = FeedUser.find_by(user_id: follower.id, action_type: 'subscription', source_id: self.exchange_id)
				user_feed_item = FeedUser.new({
					user_id: follower.id,
					action_type: 'subscription',
					source_id: self.exchange_id
				})
			end
			user_feed_item.feeds << feed
			user_feed_item.save
		end
	end

	def delete_feed
		self.feeds.where({user_id: self.user_id}).destroy_all
	end

	def self.table_name
		'exchanges_users'
	end
end