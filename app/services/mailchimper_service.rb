require 'mailchimp'

module MailchimperService
	class << self
		MAILCHIMP_SERVICE_FOR_API_LOG = "mailchimp"
		GROUPING_LABEL_WEEKLY = 'Opted into weekly roundup'
		GROUPING_LABEL_OFFERS = 'Opted into offers and promotions'
		# GROUPING_LABEL_COUNTRY = 'Country'

		def mailchimp_api
			Mailchimp::API.new(Rails.application.credentials.mailchimp[:api_key][Rails.env.to_sym])
		end

		def mailchimp_list_id
			Rails.application.credentials.mailchimp[:list_id][Rails.env.to_sym]
		end

		def mailchimp_groupings(user)
			[
				{ name: GROUPING_LABEL_WEEKLY, groups: [user.opted_into_weekly_newsletters? ? "Yes" : "No"] },
				{ name: GROUPING_LABEL_OFFERS, groups: [user.opted_into_offers? ? "Yes" : "No"] },
			]
		end

		def merge_vars(user)
			{
				FNAME: user.first_name,
				LNAME: user.last_name,
				GROUPINGS: mailchimp_groupings(user)
			}
		end

		def subscribe_to_mailchimp_list(user)
			standard_error = "Sorry there has been an error submitting your details, please try again."
			begin
				request_data = [
					mailchimp_list_id,
					{ email: user.email },
					merge_vars(user),
					'html', # email_type
					false,	# double_optin
					false,	# update_existing
					true,		# replace_interests
					false		# send_welcome
				]
				response = mailchimp_api.lists.subscribe(*request_data)
				log_mailchimp_request(user, :subscribe, request_data, response)
	    rescue Mailchimp::ListAlreadySubscribedError => e
	    	raise Exception.new("It looks like the email address #{user.email} has already been registered with TheArticle.")
	    rescue Mailchimp::Error => e
	    	raise Exception.new(standard_error)
	    rescue Exception => e
	    	raise Exception.new(standard_error)
	    end
		end

		def update_mailchimp_list(user)
			unless user.status.to_sym == :deleted
				begin
					request_data = [
						mailchimp_list_id,
						{ email: user.email },
						merge_vars(user),
						'html', # email_type
						true		# replace_interests
					]
					response = mailchimp_api.lists.update_member(*request_data)
					log_mailchimp_request(user, :update, request_data, response)
				rescue Mailchimp::Error => e
					raise e
				rescue Exception => e
					raise e
				end
		  end
		end

		def remove_from_mailchimp_list(user)
			begin
				request_data = [
					mailchimp_list_id,
					{ email: user.email },
					true, # delete_member
					false,  # send_goodbye
					false  # send_notify
				]
				response = mailchimp_api.lists.unsubscribe(*request_data)
				log_mailchimp_request(user, :remove, request_data, response)
		    rescue Mailchimp::Error => e
		    	raise e
		    end
		end

		def log_mailchimp_request(user, method_type, request_data, response)
			ApiLog.request(
				user_id: user.id,
	  		service: MAILCHIMP_SERVICE_FOR_API_LOG,
	  		request_method: method_type,
	  		request_data: request_data,
	  		response: response,
			)
		end
	end
end