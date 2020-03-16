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
		return invalid_login_attempt unless resource

		if resource.valid_password?(params[:user][:password])
			@status = :success
			resource.recalculate_follow_counts
			if request.referer == new_user_session_url
				@redirect = front_page_path
			else
				user_stored_location = stored_location_for(resource) || request.referer
				user_stored_location = nil if (user_stored_location && user_stored_location == '/notification-count')
				@redirect = user_stored_location || front_page_path
			end
			sign_in :user, resource
		else
			invalid_login_attempt
	  end
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
		logger.warn "*** Sign in debug require_no_authentication: #1"
		assert_is_devise_resource!
		logger.warn "*** Sign in debug require_no_authentication: #2"
		return unless is_navigational_format?
		logger.warn "*** Sign in debug require_no_authentication: #3"
		no_input = devise_mapping.no_input_strategies
		logger.warn "*** Sign in debug require_no_authentication: #4"

		authenticated = if no_input.present?
			logger.warn "*** Sign in debug require_no_authentication: #5"
			args = no_input.dup.push scope: resource_name
			logger.warn "*** Sign in debug require_no_authentication: #6"
			warden.authenticate?(*args)
			logger.warn "*** Sign in debug require_no_authentication: #7"
		else
			logger.warn "*** Sign in debug require_no_authentication: #8"
			warden.authenticated?(resource_name)
			logger.warn "*** Sign in debug require_no_authentication: #9"
		end

		if authenticated && resource = warden.user(resource_name)
			logger.warn "*** Sign in debug require_no_authentication: #10"
			flash[:alert] = alert = I18n.t("devise.failure.already_authenticated")
			logger.warn "*** Sign in debug require_no_authentication: #11"
			respond_to do |format|
				logger.warn "*** Sign in debug require_no_authentication: #12"
				format.html do
					logger.warn "*** Sign in debug require_no_authentication: #13"
					redirect_to "/my-home"
				end
				format.json do
					logger.warn "*** Sign in debug require_no_authentication: #14"
					render json: { status: :signed_in, message: t('devise.failure.already_authenticated') }
					logger.warn "*** Sign in debug require_no_authentication: #15"
				end
			end
		end
	end
end