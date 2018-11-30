class FeaturedImage < ApplicationRecord
	belongs_to	:article
	def caption
		"fooo"
	end
end