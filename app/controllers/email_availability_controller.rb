class EmailAvailabilityController < ApplicationController

	def new
		if user = User.find_by(email: params[:email])
			render json: false
		else
			render json: true
		end
	end
end
