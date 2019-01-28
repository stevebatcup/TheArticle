class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, :only => [:create]
  after_action  :generate_profile_suggestions, :only => [:create]
  layout	'profile-wizard'

  def create
    build_resource(sign_up_params)
    resource.set_ip_data(request)
    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def generate_profile_suggestions
  	unless resource.id.nil?
	  	ProfileSuggestionsGeneratorJob.perform_later(resource, true, 10)
	  end
  end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:title, :first_name, :last_name, :email, :password])
    end
end