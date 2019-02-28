class ProfileSuggestionsController < ApplicationController
	before_action :authenticate_user!

	def index
		respond_to do |format|
			format.json do
				@from_wizard = params[:from_wizard].present?
				if params[:query]
					@search_results = User.search_for_suggestions(current_user, params[:query])
				else
					if params[:show_accepted]
						# SWITCHED OFF FOR LAUNCH #
						# suggestions = current_user.profile_suggestions
						# REPLACED WITH #
						@suggestions = User.popular_users([current_user.id], 0, 150)
						render 'index_launch'
					else
						suggestions = current_user.pending_suggestions
						current_user.generate_suggestions(false, 10) if suggestions.empty?
						@for_yous = suggestions.where.not("reason LIKE ?", 'popular_with_%')
						@populars = suggestions.where("reason LIKE ?", 'popular_with_%')
					end
				end
			end
			format.html
		end
	end
end
