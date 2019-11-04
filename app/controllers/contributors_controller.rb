class ContributorsController < ApplicationController
	def index
		respond_to do |format|
			list = Author.with_complete_profile.order("last_name ASC")
			@contributors = Author.prioritise_editors_in_list(list.to_a)
			format.html do
			end
			format.json do
			end
		end
	end

	def show
		if request.path.include?("contributors")
			redirect_to contributor_path(slug: params[:slug]), :status => 301
		else
			if @contributor = Author.find_by(slug: params[:slug])
				if @contributor.is_sponsor?
					redirect_to sponsor_path(slug: params[:slug])
				else
					@contributors_for_carousel = Author.with_complete_profile(@contributor.id).limit(25).shuffle
					@ratings = []
					# if user_signed_in?
					# 	@ratings = @contributor.get_avg_ratings_by_user(current_user)
					# end
				end
			else
				render_404
			end
		end
	end
end
