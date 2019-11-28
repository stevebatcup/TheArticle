class LandingPagesController < ApplicationController
	def show
		@landing_page = LandingPage.find(params[:id])
	end
end