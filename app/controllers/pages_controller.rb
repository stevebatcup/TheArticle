class PagesController < ApplicationController
	layout	:set_layout

	def show
		@page = Page.find(params[:id])
	end
end