class UsernameAvailabilityController < ApplicationController
	before_action :authenticate_user!

	def new
		if current_user.username = params[:username]
			render json: true
		elsif User.is_username_available?(params[:username])
			current_user.update_attribute(:username, params[:username].strip) if params[:save].present?
			render json: true
		else
			render json: false
		end
	end
end
