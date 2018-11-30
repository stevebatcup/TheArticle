class RegisterController < ApplicationController
	def create
		begin
			MailchimperService.subscribe_to_mailchimp_list(params)
			render json: { status: 'success' }
		rescue Exception => e
			render json: { status: 'error', message: e.message }
		end
	end
end