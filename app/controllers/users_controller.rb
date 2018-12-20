class UsersController < ApplicationController
	before_action :authenticate_user!

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

		if (@user == current_user) && !params[:me]
			redirect_to_my_profile
		end
	end

	def update
		if params[:cover_photo]

		elsif params[:profile_photo]

		else
			if current_user.update_attributes({
					display_name: params[:profile][:display_name],
					username: params[:profile][:username],
					location: params[:profile][:location],
					bio: params[:profile][:bio]
				})
				@status = :success
			else
				@status = :error
				@message = current_user.errors.full_messages.first
			end
		end
	end

private

	def redirect_to_my_profile
		redirect_to my_profile_path
		# if browser.device.mobile?
		# 	redirect_to "/front-page?route=myprofile"
		# else
		# end
	end
end