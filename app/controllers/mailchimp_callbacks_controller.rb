class MailchimpCallbacksController < ApplicationController
	def show
		render	json: { status: :success }
	end

	def update
		if params[:type] == "unsubscribe"
			api_log_data = {
				service: MailchimperService::MAILCHIMP_SERVICE_FOR_API_LOG,
				request_data: mailchimp_params,
				request_method: :unsubscribe
			}
			if user = User.find_by(email: mailchimp_params[:email])
				user.unsubscribe_all_emails
				api_log_data[:user_id] = user.id
				response = { status: :success }
			else
				response = { status: :error, message: "User not found" }
			end
		elsif params[:type] == "profile"
			sleep(10) # allow the update email call to finish first
			api_log_data = {
				service: MailchimperService::MAILCHIMP_SERVICE_FOR_API_LOG,
				request_data: mailchimp_params,
				request_method: :update_profile
			}
			if user = User.find_by(email: mailchimp_params[:email])
				new_data = {
					first_name: mailchimp_params[:merges][:FNAME],
					last_name: mailchimp_params[:merges][:LNAME],
					email: mailchimp_params[:merges][:EMAIL]
				}
				user.update_attributes(new_data)
				user.set_opted_into_weekly_newsletters(params[:data][:merges][weekly_key] == "Yes" ? true : false)
				user.set_opted_into_offers(params[:data][:merges][offers_key] == "Yes" ? true : false)
				api_log_data[:user_id] = user.id
				response = { status: :success }
			else
				response = { status: :error, message: "User not found" }
			end
		elsif params[:type] == "upemail"
			api_log_data = {
				service: MailchimperService::MAILCHIMP_SERVICE_FOR_API_LOG,
				request_data: mailchimp_params,
				request_method: :update_email
			}
			if mailchimp_params[:old_email] == mailchimp_params[:new_email]
				response = { status: :error, message: "Email address not updated" }
			elsif user = User.find_by(email: mailchimp_params[:old_email])
				user.skip_reconfirmation!
				user.update_attribute(:email, mailchimp_params[:new_email])
				api_log_data[:user_id] = user.id
				response = { status: :success }
			else
				response = { status: :error, message: "User not found" }
			end
		end

		api_log_data[:response] = response
		ApiLog.webhook(api_log_data)
		render	json: response
	end

private

	def mailchimp_params
		params.require(:data).permit(:email, :new_email, :old_email, merges: [ :FNAME, :LNAME, :EMAIL, offers_key, weekly_key ])
	end

	def offers_key
		MailchimperService::GROUPING_LABEL_OFFERS
	end

	def weekly_key
		MailchimperService::GROUPING_LABEL_WEEKLY
	end
end
