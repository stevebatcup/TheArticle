class UsernameAvailabilityController < ApplicationController
	def new
		if User.is_username_available?(params[:username])
			render json: true
		else
			render json: false
		end
	end
end
