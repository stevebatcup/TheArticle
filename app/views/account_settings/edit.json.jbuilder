json.set! :user do
	json.id current_user.id

	json.title current_user.title
	json.firstName current_user.first_name
	json.lastName current_user.last_name
	json.fullName current_user.full_name

	fullUsername = current_user.username
	json.username fullUsername[1..-1]
	json.originalUsername fullUsername

	json.displayName current_user.display_name

	email = current_user.email
	json.email email
	json.cleanEmail email

	json.password ''

	json.profileDeactivated current_user.profile_is_deactivated?
	json.confirmingPassword ''

	json.emailNotificationStatus current_user.all_notification_settings_are_off? ? 'Off' : 'On'

	json.set!	:notificationSettings do
		current_user.notification_settings.each do |setting|
			json.set! setting.key.camelize.lcfirst, setting.value
		end
	end

	json.set!	:communicationPreferences do
		current_user.communication_preferences.each do |preference|
			json.set! preference.preference.camelize.lcfirst, preference.status
		end
	end
end