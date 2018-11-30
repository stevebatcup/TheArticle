class RegisterController < ApplicationController
	def create
		begin
			MailchimperService.subscribe_to_mailchimp_list(params)
			UserMailer.send_welcome(params[:email], params[:first_name], params[:last_name]).deliver_now
			render json: { status: 'success' }
		rescue Exception => e
			render json: { status: 'error', message: e.message }
		end
	end
end