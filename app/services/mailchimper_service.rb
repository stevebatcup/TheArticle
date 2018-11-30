require 'mailchimp'

module MailchimperService
	class << self
		def mailchimp_api
			Mailchimp::API.new(Rails.application.credentials.mailchimp[:api_key][Rails.env.to_sym])
		end

		def mailchimp_list_id
			Rails.application.credentials.mailchimp[:list_id][Rails.env.to_sym]
		end

		def subscribe_to_mailchimp_list(user_data)
			standard_error = "sSorry there has been an error submitting your details, please try again."
			begin
				request_data = [
					mailchimp_list_id,
					{ email: user_data['email'] },
					{
						FNAME: user_data['first_name'],
						LNAME: user_data['last_name']
					},
					'html', # email_type
					false,	# double_optin
					false,	# update_existing
					true,		# replace_interests
					false		# send_welcome
				]
				response = mailchimp_api.lists.subscribe(*request_data)
				# log_mailchimp_request(:subscribe, request_data, response)
	    rescue Mailchimp::ListAlreadySubscribedError => e
	    	raise Exception.new("It looks like the email address #{user_data['email']} has already been registered with TheArticle.")
	    rescue Mailchimp::Error => e
	    	raise Exception.new(standard_error)
	    rescue Exception => e
	    	raise Exception.new(standard_error)
	    end
		end
	end

end