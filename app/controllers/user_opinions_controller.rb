class UserOpinionsController < ApplicationController
	before_action :authenticate_user!, except: [:index]

	def index
		respond_to do |format|
			format.json do
				page = (params[:page] || 1).to_i
				per_page = (params[:per_page] || 6).to_i
				if params[:id]
					@user = User.find(params[:id])
				else
					@user = current_user
				end
				if page == 1
					@total = @user.feeds.where(actionable_type: 'Opinion').size
				end
				@opinions = @user.feeds.where(actionable_type: 'Opinion').page(page).per(per_page).order(created_at: :desc)
			end
		end
	end
end