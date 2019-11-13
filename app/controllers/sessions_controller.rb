class SessionsController < Devise::SessionsController
	# after_action  :generate_profile_suggestions, :only => [:create]
	layout	:profile_wizard_layout_for_mobile

	def new
		respond_to do |format|
			format.html do
				redirect_to	"/?sign_in=1"
			end
			format.json
		end
	end

	def create
	  resource = User.find_for_database_authentication(login: params[:user][:login])
	  return invalid_login_attempt unless resource

	  if resource.valid_password?(params[:user][:password])
	    @status = :success
	    sign_in_url = new_user_session_url
	    resource.recalculate_follow_counts
      if request.referer == sign_in_url
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
end