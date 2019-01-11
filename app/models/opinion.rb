class Opinion < ApplicationRecord
  has_many :feeds, as: :actionable
	belongs_to	:user
	belongs_to	:share
	before_create	:update_feed
	after_destroy	:delete_feed

	def update_feed
		self.feeds.build({user_id: self.user_id})
	end

	def delete_feed
		self.feeds.destroy_all
	end

	def self.show_limit
		10
	end
end
