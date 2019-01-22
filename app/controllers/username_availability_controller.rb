class UsernameAvailabilityController < ApplicationController
	before_action :authenticate_user!

	def new
		if User.is_username_available?(params[:username])
			render json: true
		else
			render json: false
		end
	end
end
