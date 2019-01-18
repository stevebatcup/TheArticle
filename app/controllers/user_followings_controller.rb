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
				@userFollowings = user.followings.page(page).per(per_page).map(&:followed)
				@userFollowers = user.followers.page(page).per(per_page)
			end
		end
	end

	def create
		@status = ''
		other_user = User.find(params[:id])
		if current_user.has_blocked(other_user)
			@status = :error
			@message = "You are blocking this user so you cannot follow them"
		elsif other_user.has_blocked(current_user)
			@status = :error
			@message = "You are currently blocked by this user so you cannot follow them"
		end

		if @status != :error
			current_user.followings << Follow.new({followed_id: params[:id]})
			if current_user.save
				@status = :success
				current_user.accept_suggestion_of_user_id(params[:id]) if params[:from_suggestion]
			else
				@status = :error
				@message = current_user.errors.full_messages
			end
		end
	end

	def destroy
		if current_user.followings.where(followed_id: params[:id]).first.destroy
			@status = :success
		else
			@status = :error
		end
	end
end
