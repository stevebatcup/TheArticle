class ProfileSuggestionsController < ApplicationController
	before_action :authenticate_user!

	def index
		respond_to do |format|
			format.json do
				suggestions = current_user.pending_suggestions
				@for_yous = suggestions.where.not("reason LIKE ?", 'popular_with_%')
				@populars = suggestions.where("reason LIKE ?", 'popular_with_%')
			end
			format.html
		end
	end
end
