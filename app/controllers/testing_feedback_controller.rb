class TestingFeedbackController < ApplicationController
	def create
		feedback = FeedbackSubmission.new(feedback_params)
		if feedback.save
			render json: { status: :success }
			FeedbackMailer.submit(feedback).deliver_now
		else
			render json: { status: :error, message: feedback.errors.full_messages }
		end
	end

	def accept
		if cookies.permanent[:cookie_test_environment_seen] = true
			render json: { status: 'success' }
		else
			render json: { status: 'error' }
		end
	end

private

	def feedback_params
		params.require(:feedback).permit(:url, :browser, :device, :platform, :name, :comments)
	end
end