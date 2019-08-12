class PagesController < ApplicationController

	def show
		respond_to do |format|
			@page = Page.find(params[:id])
			format.html do
			end
			format.json do
			end
		end
	end
end