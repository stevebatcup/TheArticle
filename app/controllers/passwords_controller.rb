class PasswordsController < Devise::PasswordsController
	layout	:profile_wizard_layout_for_mobile
  respond_to :json, only: [:create]

  def create
    self.resource = resource_class.send_reset_password_instructions(params.fetch(:user))

    if successfully_sent?(resource)
    	render	json: { message: t('devise.passwords.send_paranoid_instructions') }, status: 200
    else
      render	json: { message: t('devise.passwords.send_paranoid_instructions') }, status: 401
    end
  end


protected
	def after_resetting_password_path_for(resource)
		"#{after_sign_in_path_for(resource)}?password_changed=1"
	end
end
