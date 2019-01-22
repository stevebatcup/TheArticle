class NotificationSettingsController < ApplicationController
	before_action :authenticate_user!

	def update
		key = settings_params[:key].underscore
		setting = current_user.notification_settings.find_by(key: key)
		if setting && setting.update_attribute(:value, settings_params[:value])
			@status = :success
		else
			@status = :error
		end
	end

private
	def settings_params
		params.require(:settings).permit(:key, :value)
	end
end
