class SponsorsController < ApplicationController
	def index
		@sponsors = Author.sponsors_for_listings.order(display_name: :asc)
	end

	def show
		if @sponsor = Author.find_by(slug: params[:slug])
			@sponsors_for_carousel = Author.with_complete_profile(@sponsor.id).shuffle
		else
			render_404
		end
	end
end