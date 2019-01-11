class Subscription < ApplicationRecord
  has_many :feeds, as: :actionable
	belongs_to	:user
	belongs_to	:exchange
	before_create	:update_feed
	after_destroy	:delete_feed

	def update_feed
		self.feeds.build({user_id: self.user_id})
	end

	def delete_feed
		self.feeds.where({user_id: self.user_id}).destroy_all
	end

	def self.table_name
		'exchanges_users'
	end
end