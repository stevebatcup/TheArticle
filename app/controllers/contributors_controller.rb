class ContributorsController < ApplicationController
	def index
		list = Author.with_complete_profile().order("last_name ASC")
		@contributors = Author.prioritise_editors_in_list(list.to_a)
	end

	def show
		if @contributor = Author.find_by(slug: params[:slug])
			@contributors_for_carousel = Author.with_complete_profile(@contributor.id).limit(25).shuffle
		else
			render_404
		end
	end
end
