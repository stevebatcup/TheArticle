class ProfileSuggestionsController < ApplicationController
	before_action :authenticate_user!

	def index
		respond_to do |format|
			format.json do
				if params[:query]
					@search_results = User.search_for_suggestions(current_user, params[:query])
				else
					if params[:show_accepted]
						suggestions = current_user.profile_suggestions
					else
						suggestions = current_user.pending_suggestions
					end
					current_user.generate_suggestions(false, 10) if suggestions.empty?
					@for_yous = suggestions.where.not("reason LIKE ?", 'popular_with_%')
					@populars = suggestions.where("reason LIKE ?", 'popular_with_%')
				end
			end
			format.html
		end
	end
end
