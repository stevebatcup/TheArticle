class UserFollowingsController < ApplicationController
	def index
		if params[:id]
			user = User.find(params[:id])
			@userFollowings = user.followings.map(&:followed)
			@userFollowers = user.followers
		else
			@userFollowings = current_user.followings.map(&:followed)
			@userFollowers = current_user.followers
		end
	end

	def create
		current_user.followings << Follow.new({followed_id: params[:id]})
		if current_user.save
			@status = :success
			current_user.accept_suggestion_of_user_id(params[:id]) if params[:from_suggestion]
		else
			@status = :error
			@message = current_user.errors.full_messages
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
