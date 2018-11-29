class ContributorsController < ApplicationController
	def index
		@contributors = Author.contributors_with_complete_profile.order(:display_name)
	end

	def show
		@contributor = Author.find_by(slug: params[:slug])
		@contributors_for_carousel = Author.contributors_with_complete_profile(@contributor.id).shuffle
	end
end
