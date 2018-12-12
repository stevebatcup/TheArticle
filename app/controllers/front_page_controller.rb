class FrontPageController < ApplicationController
	before_action :authenticate_user!
	layout	:set_layout

	def index

	end
end
