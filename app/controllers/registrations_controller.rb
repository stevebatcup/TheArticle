class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, :only => [:create]
  after_action  :generate_profile_suggestions, :only => [:create]
  layout	'profile-wizard'

  def new
    respond_to do |format|
      format.html do
        if browser.device.mobile?
          super
        else
          redirect_to "/?register=1"
        end
      end
    end
  end

  def create
    build_resource(sign_up_params)
    resource.set_ip_data(request)

    if !verify_recaptcha(model: resource, secret_key: Rails.application.credentials.recaptcha_secret_key) && !request.headers["X-MobileApp"] && Rails.env.production?
      fail_registration(resource)
    else
      resource.registration_source = request.headers["X-MobileApp"] ? 'mobile app' : 'website'
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
        fail_registration(resource)
      end
    end

    respond_to do |format|
      format.html do
        if @status == :success
          response.headers["user_signed_in"] = 1
          respond_with resource, location: @redirect_to
        else
          respond_with resource
        end
      end

      format.json do
        response.headers["user_signed_in"] = 1 if @status == :success
      end
    end
  end


protected

  def generate_profile_suggestions
  	unless resource.id.nil?
	  	ProfileSuggestionsGeneratorJob.perform_later(resource, true, 50)
	  end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:title, :first_name, :last_name, :email, :password, :age_bracket, :gender])
  end

private

  def fail_registration(resource)
    @status = :error
    @message = better_model_error_messages(resource)
    clean_up_passwords resource
    set_minimum_password_length
  end

   def require_no_authentication
     assert_is_devise_resource!
     return unless is_navigational_format?
     no_input = devise_mapping.no_input_strategies

     authenticated = if no_input.present?
       args = no_input.dup.push scope: resource_name
       warden.authenticate?(*args)
     else
       warden.authenticated?(resource_name)
     end

     if authenticated && resource = warden.user(resource_name)
       flash[:alert] = alert = I18n.t("devise.failure.already_authenticated")
        respond_to do |format|
          format.html do
           redirect_to "/my-home"
          end
          format.json do
            render json: { status: :error, message: t('devise.failure.already_authenticated') }, status: 401
          end
        end
     end
   end

end