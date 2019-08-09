class SponsorsController < ApplicationController
	def index
		respond_to do |format|
			@sponsors = Author.sponsors_for_listings.order(display_name: :asc)
			format.html do
			end
			format.json do
			end
		end
	end

	def show
		if @sponsor = Author.find_by(slug: params[:slug])
			@sponsors_for_carousel = Author.with_complete_profile(@sponsor.id).shuffle
		else
			render_404
		end
	end
end