class ContributorsController < ApplicationController
	def index
		list = Author.with_complete_profile().order(:display_name)
		@contributors = Author.prioritise_editors_in_list(list.to_a)
	end

	def show
		@contributor = Author.find_by(slug: params[:slug])
		@contributors_for_carousel = Author.with_complete_profile(@contributor.id).shuffle
	end
end
