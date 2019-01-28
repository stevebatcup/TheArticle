class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, :only => [:create]
  after_action  :generate_profile_suggestions, :only => [:create]
  # after_action  :set_ip_data, :only => [:create]
  layout	'profile-wizard'

  def generate_profile_suggestions
  	unless resource.id.nil?
	  	ProfileSuggestionsGeneratorJob.perform_later(resource, true, 10)
	  end
  end

  def set_ip_data
    resource.set_ip_data(request)
  end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:title, :first_name, :last_name, :email, :password])
    end
end