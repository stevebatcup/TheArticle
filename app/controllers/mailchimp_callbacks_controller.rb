class MailchimpCallbacksController < ApplicationController
	def show
		render	json: { status: :success }
	end

	def update
		if params[:type] == "unsubscribe"
		# "fired_at": "2009-03-26 21:40:57",
		# "data[action]": "unsub",
		# "data[reason]": "manual",
		# "data[id]": "8a25ff1d98",
		# "data[list_id]": "a6b5da1054",
		# "data[email]": "api+unsub@mailchimp.com",
		# "data[email_type]": "html",
		# "data[merges][EMAIL]": "api+unsub@mailchimp.com",
		# "data[merges][FNAME]": "Mailchimp",
		# "data[merges][LNAME]": "API",
		# "data[merges][INTERESTS]": "Group1,Group2",
		# "data[ip_opt]": "10.20.10.30",
		# "data[campaign_id]": "cb398d21d2",
		# "data[reason]": "hard"

		elsif params[:type] == "profile"
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
			api_log_data[:response] = response
			ApiLog.webhook(api_log_data)
			render	json: response

		elsif params[:type] == "upemail"
			api_log_data = {
				service: MailchimperService::MAILCHIMP_SERVICE_FOR_API_LOG,
				request_data: mailchimp_params,
				request_method: :update_email
			}
			if user = User.find_by(email: mailchimp_params[:old_email])
				user.skip_reconfirmation!
				user.update_attribute(:email, mailchimp_params[:new_email])
				api_log_data[:user_id] = user.id
				response = { status: :success }
			else
				response = { status: :error, message: "User not found" }
			end
			api_log_data[:response] = response
			ApiLog.webhook(api_log_data)
			render	json: response

			# "fired_at": "2009-03-26 22:15:09",
			# "data[list_id]": "a6b5da1054",
			# "data[new_id]": "51da8c3259",
			# "data[new_email]": "api+new@mailchimp.com",
			# "data[old_email]": "api+old@mailchimp.com"
		end

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
