class HelpController < ApplicationController
	def index
		@section = params[:section] || nil
	end
end