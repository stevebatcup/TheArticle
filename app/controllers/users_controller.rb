class UsersController < ApplicationController
	def index
		@users = User.all
	end

	def show
		if params[:me]
			@user = current_user
		elsif params[:identifier] == :slug
			@user = User.find_by(slug: params[:slug])
		elsif params[:identifier] == :id
			@user = User.find_by(id: params[:id])
		end

		redirect_to my_profile_path if (@user == current_user) && !params[:me]
	end
end