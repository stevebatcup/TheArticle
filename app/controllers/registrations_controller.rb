class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, :only => [:create]
  after_action  :generate_profile_suggestions, :only => [:create]

  def generate_profile_suggestions
  	ProfileSuggestionsGeneratorJob.perform_later(resource, true, 10)
  end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:title, :first_name, :last_name, :email, :password])
    end
end