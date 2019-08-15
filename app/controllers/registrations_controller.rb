class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, :only => [:create]
  after_action  :generate_profile_suggestions, :only => [:create]
  layout	'profile-wizard'

  def new
    respond_to do |format|
      format.html do
        redirect_to "/?register=1"
      end
    end
  end

  def create
    build_resource(sign_up_params)
    resource.set_ip_data(request)
    resource.save
    yield resource if block_given?
    if resource.persisted? && resource.active_for_authentication?
      begin
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        MailchimperService.subscribe_to_mailchimp_list(resource)
      rescue Exception => e
        @status = :error
        @message = e.message
      end
      @status = :success
      @redirect_to = after_sign_up_path_for(resource)
    else
      @status = :error
      @message = resource.errors.first
      clean_up_passwords resource
      set_minimum_password_length
    end

    respond_to do |format|
      format.html do
        if @status == :success
          respond_with resource, location: @redirect_to
        else
          respond_with resource
        end
      end

      format.json do
      end
    end
  end

  def generate_profile_suggestions
  	unless resource.id.nil?
	  	ProfileSuggestionsGeneratorJob.perform_later(resource, true, 50)
	  end
  end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:title, :first_name, :last_name, :email, :password, :age_bracket, :gender])
    end
end