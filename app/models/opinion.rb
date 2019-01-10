class Opinion < ApplicationRecord
	belongs_to	:user
	belongs_to	:share

	def self.show_limit
		10
	end
end
