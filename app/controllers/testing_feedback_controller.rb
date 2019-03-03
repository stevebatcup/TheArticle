class TestingFeedbackController < ApplicationController
	def accept
		if cookies.permanent[:cookie_test_environment_seen] = true
			render json: { status: 'success' }
		else
			render json: { status: 'error' }
		end
	end
end