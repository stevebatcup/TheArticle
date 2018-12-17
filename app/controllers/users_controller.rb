class UsersController < ApplicationController
	def show
		@user = User.find_by(slug: params[:slug])
	end
end