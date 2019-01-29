class PasswordsController < Devise::PasswordsController
  layout	'profile-wizard'

protected
	def after_resetting_password_path_for(resource)
		"#{after_sign_in_path_for(resource)}?password_changed=1"
	end
end
