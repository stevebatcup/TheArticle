class CommunicationPreferencesController < ApplicationController
	before_action :authenticate_user!

	def update
		key = preferences_params[:preference].underscore
		preference = current_user.communication_preferences.find_by(preference: key)
		if preference
			if preference.update_attribute(:status, preferences_params[:status])
				MailchimperService.update_mailchimp_list(current_user)
				@status = :success
			else
				@status = :error
				@message = preference.errors.full_messages.first
			end
		else
			@status = :error
			@message = "Preference not found"
		end
	end

private
	def preferences_params
		params.require(:preferences).permit(:preference, :status)
	end
end
