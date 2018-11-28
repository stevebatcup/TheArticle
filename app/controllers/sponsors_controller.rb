class SponsorsController < ApplicationController
	def index
		@sponsors = Author.sponsors_for_listings
	end
end