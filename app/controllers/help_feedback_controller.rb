class HelpFeedbackController < ApplicationController
	def new
		HelpFeedback.create({
			question_id: params[:question_id],
			outcome: params[:outcome],
			user_id: user_signed_in? ? current_user.id : nil
		})
	end
end