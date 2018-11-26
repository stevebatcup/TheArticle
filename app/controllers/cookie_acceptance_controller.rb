class CookieAcceptanceController < ApplicationController
	def new
		if cookies[:cookie_permission_set] = true
			render json: { status: 'success' }
		else
			render json: { status: 'error' }
		end
	end
end