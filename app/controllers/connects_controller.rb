class ConnectsController < ApplicationController
	before_action :authenticate_user!

	def index
		@connects = current_user.connects
	end
end