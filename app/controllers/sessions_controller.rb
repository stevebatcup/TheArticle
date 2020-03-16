class SessionsController < Devise::SessionsController
	# after_action  :generate_profile_suggestions, :only => [:create]
	layout	:profile_wizard_layout_for_mobile

	def new
		respond_to do |format|
			format.html do
				if browser.device.mobile?
					super
				else
					redirect_to	"/?sign_in=1"
				end
			end
			format.json
		end
	end

	def create
		logger.warn "*** Sign in debug pre-find: #1 (#{params[:user][:login]})"
		resource = User.find_for_database_authentication(login: params[:user][:login])
		logger.warn "*** Sign in debug: #2 (#{resource.username})"
		return invalid_login_attempt unless resource
		logger.warn "*** Sign in debug: #3 (#{resource.username})"

		if resource.valid_password?(params[:user][:password])
			logger.warn "*** Sign in debug: #4 (#{resource.username})"
			@status = :success
			logger.warn "*** Sign in debug: #5 (#{resource.username})"
			resource.recalculate_follow_counts
			logger.warn "*** Sign in debug: #6 (#{resource.username})"
			if request.referer == new_user_session_url
				logger.warn "*** Sign in debug: #7 (#{resource.username})"
				@redirect = front_page_path
			else
				logger.warn "*** Sign in debug: #8 (#{resource.username})"
				user_stored_location = stored_location_for(resource) || request.referer
				logger.warn "*** Sign in debug: #9 (#{resource.username})"
				user_stored_location = nil if (user_stored_location && user_stored_location == '/notification-count')
				logger.warn "*** Sign in debug: #10 (#{resource.username})"
				@redirect = user_stored_location || front_page_path
				logger.warn "*** Sign in debug: #11 (#{resource.username})"
			end
			logger.warn "*** Sign in debug: #12 (#{resource.username})"
			sign_in :user, resource
			logger.warn "*** Sign in debug: #13 (#{resource.username})"
		else
			invalid_login_attempt
	  end
	  logger.warn "*** Sign in debug: #14 (#{resource.username})"
	end

	def destroy
		super
		flash.delete(:notice)
		cookies[:shown_registration_interstitial] = { :value => true, :expires => 24.hours.from_now }
	end

	def set_stored_location
		session["user_return_to"] = params["return_to"]
		render json: { status: :success }
	end

protected

	def invalid_login_attempt
	  render json: { status: t('devise.sessions.user.invalid') }, status: 401
	end

  def generate_profile_suggestions
   	ProfileSuggestionsGeneratorJob.perform_later(resource, false, 25)
  end

 private

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
		      	render json: { status: :signed_in, message: t('devise.failure.already_authenticated') }
		      end
		    end
     end
   end
end