class FrontPageController < ApplicationController
	before_action :authenticate_user!
	layout	'member'

	def index

	end
end
