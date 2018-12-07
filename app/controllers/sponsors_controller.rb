class SponsorsController < ApplicationController
	layout	:set_layout

	def index
		@sponsors = Author.sponsors_for_listings
	end

	def show
		@sponsor = Author.find_by(slug: params[:slug])
		@sponsors_for_carousel = Author.with_complete_profile(@sponsor.id).shuffle
	end
end