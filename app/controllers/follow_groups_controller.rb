class FollowGroupsController < ApplicationController
	def show
		@follow_group = FollowGroup.find(params[:id])
	end
end
