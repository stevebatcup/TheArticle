class UsersController < ApplicationController
	def show
		if params[:me]
			@user = current_user
		else
			@user = User.find_by(slug: params[:slug])
		end
	end
end