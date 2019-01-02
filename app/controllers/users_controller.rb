class UsersController < ApplicationController
	before_action :authenticate_user!, except: [:show]

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
		profile_params = params[:profile]
		if profile_params[:mode] == 'coverPhoto'
			current_user.cover_photo = profile_params[:photo]
			if current_user.save
				@status = :success
			else
				@status = :error
				@message = current_user.errors.full_messages.first
			end
		elsif profile_params[:mode] == 'profilePhoto'
			current_user.profile_photo = profile_params[:photo]
			if current_user.save
				@status = :success
			else
				@status = :error
				@message = current_user.errors.full_messages.first
			end
		else
			if current_user.update_attributes({
					display_name: profile_params[:display_name],
					username: profile_params[:username],
					location: profile_params[:location],
					bio: profile_params[:bio]
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