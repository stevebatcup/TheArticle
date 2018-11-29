class RegisterController < ApplicationController
	def create
		render json: { status: 'xsuccess' }
	end
end