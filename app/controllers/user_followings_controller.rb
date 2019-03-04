class UserFollowingsController < ApplicationController
	def index
		respond_to do |format|
			format.json do
				page = (params[:page] || 1).to_i
				per_page = (params[:per_page] || 6).to_i
				if params[:id]
					user = User.find(params[:id])
				else
					user = current_user
				end
				if page == 1
					@total = Follow.both_directions_for_user(user).size
				end
				@userFollowings = user.followings.order("created_at DESC").page(page).per(per_page).map(&:followed)
				@userFollowers = user.followers.order("created_at DESC").page(page).per(per_page)
			end
		end
	end

	def create
		@status = ''
		other_user = User.find(params[:id])
		if current_user.profile_is_deactivated?
			@status = :error
			@message = "You must reactivate your profile in order to follow #{other_user.display_name}"
		elsif current_user.has_blocked(other_user)
			@status = :error
			@message = "You are blocking this user so you cannot follow them"
		elsif other_user.has_blocked(current_user)
			@status = :error
			@message = "You are currently blocked by this user so you cannot follow them"
		elsif other_user.profile_is_deactivated?
			@status = :error
			@message = "Sorry this user is currently deactivated"
		elsif other_user.is_followed_by(current_user)
			@status = :error
			@message = "You are already following #{other_user.display_name}"
		end

		if @status != :error
			current_user.followings << Follow.new({followed_id: params[:id]})
			if current_user.save
				@status = :success
				flash[:notice] = "You are now following <b>#{other_user.display_name}</b>" if params[:set_flash]
				current_user.accept_suggestion_of_user_id(params[:id])
				# Rails.cache.delete("followings_count_#{current_user.id}")
				# Rails.cache.delete("followers_count_#{params[:id]}")
			else
				@status = :error
				@message = current_user.errors.full_messages
			end
		end
	end

	def destroy
		other_user = User.find(params[:id])
		if current_user.followings.where(followed_id: params[:id]).first.destroy
			flash[:notice] = "You are no longer following <b>#{other_user.display_name}</b>" if params[:set_flash]
			@status = :success
		else
			@status = :error
		end
	end

	def my_followers_of
		@followed = User.find(params[:id])
		@followers = current_user.followings.map(&:followed).select! do |my_following|
			@followed.is_followed_by(my_following)
		end
	end

	def mute
		current_user.mute_followed(params[:id])
		render json: { status: :success }
	end
end
