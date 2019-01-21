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

	json.email current_user.email
	json.password ''

	json.profileDeactivated current_user.profile_is_deactivated?
	json.confirmingPassword false
end