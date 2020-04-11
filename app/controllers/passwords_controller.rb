class PasswordsController < Devise::PasswordsController
	layout	:profile_wizard_layout_for_mobile
  respond_to :json, only: [:create]

  def new
    respond_to do |format|
      format.html do
        redirect_to "/?forgotten_password=1"
      end
    end
  end

  def create
    self.resource = resource_class.send_reset_password_instructions(params.fetch(:user))

    if successfully_sent?(resource)
    	render	json: { message: t('devise.passwords.send_paranoid_instructions') }, status: 200
    else
      render	json: { message: t('devise.passwords.send_paranoid_instructions') }, status: 401
    end
  end

  def update
    self.resource = resource_class.reset_password_by_token(params.fetch(:user))

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      UserMailer.password_change_confirmed(self.resource).deliver_now
      if resource.active_for_authentication?
        flash_message = "updated"
        sign_in(resource_name, resource)
      else
        flash_message = "updated_not_active"
      end
      render json: { message: t("devise.passwords.#{flash_message}") }, status: 200
    else
      set_minimum_password_length
      render json: { message: better_model_error_messages(resource) }, status: 500
    end
  end

  protected

	def after_resetting_password_path_for(resource)
		"#{after_sign_in_path_for(resource)}?password_changed=1"
	end
end
