class MailchimpCallbacksController < ApplicationController
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
			ApiLog.webhook(params)
			# if user = User.find_by(email: params[:data][:email])
			# 	new_data = {
			# 		first_name: params[:data][:merges][:FNAME],
			# 		last_name: params[:data][:merges][:LNAME],
			# 		email: params[:data][:merges][:EMAIL],
			# 	}
			# 	user.update_atttributes(new_data)
			# 	weekly_key = MailchimperService.GROUPING_LABEL_WEEKLY
			# 	user.set_opted_into_weekly_newsletters(params[:data][:merges][weekly_key] == "Yes" ? true : false)
			# 	offers_key = MailchimperService.GROUPING_LABEL_OFFERS
			# 	user.set_opted_into_offers(params[:data][:merges][offers_key] == "Yes" ? true : false)
			# end
			# "fired_at": "2009-03-26 21:31:21",
			# "data[id]": "8a25ff1d98",
			# "data[list_id]": "a6b5da1054",
			# "data[email]": "api@mailchimp.com",
			# "data[email_type]": "html",
			# "data[merges][EMAIL]": "api@mailchimp.com",
			# "data[merges][FNAME]": "Mailchimp",
			# "data[merges][LNAME]": "API",
			# "data[merges][INTERESTS]": "Group1,Group2",
			# "data[ip_opt]": "10.20.10.30"

		elsif params[:type] == "upemail"
			# "fired_at": "2009-03-26 22:15:09",
			# "data[list_id]": "a6b5da1054",
			# "data[new_id]": "51da8c3259",
			# "data[new_email]": "api+new@mailchimp.com",
			# "data[old_email]": "api+old@mailchimp.com"

		end

	end
end
