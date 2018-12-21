class UserFollowingsController < ApplicationController
	before_action :authenticate_user!

	# def index
	# 	@userFollowings = current_user.followings
	# end

	def create
		current_user.followings << Follow.new({followed_id: params[:id]})
		if current_user.save
			@status = :success
		else
			@status = :error
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
