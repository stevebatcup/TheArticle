class Categorisation < ApplicationRecord
  has_many :feeds, as: :actionable
	belongs_to	:article
	belongs_to	:exchange
	before_create	:update_feeds
	after_destroy	:delete_feeds

	def update_feeds
		self.exchange.users.each do |user|
			self.feeds.build({user_id: user.id})
		end
	end

	def delete_feeds
		self.feeds.destroy_all
	end

	def self.table_name
		'articles_exchanges'
	end
end