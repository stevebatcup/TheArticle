class Subscription < ApplicationRecord
	belongs_to	:user
	belongs_to	:exchange

	def self.table_name
		'exchanges_users'
	end
end