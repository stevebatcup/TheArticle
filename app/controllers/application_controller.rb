class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: "londonbridge", password: "B37ys0m2w" if Rails.env == 'staging'
  http_basic_authenticate_with name: "borehamwood", password: "N5T0d341Vh" if Rails.env == 'production'
	before_action :set_device_type
  protect_from_forgery with: :exception, if: Proc.new { |c| c.request.format != 'application/json' }
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  skip_before_action :verify_authenticity_token, if: :json_request?
  before_action :set_vary_header
  before_action :configure_permitted_parameters, if: :devise_controller?

	def not_found
	  raise ActionController::RoutingError.new('Not Found')
	end

	def render_404
		render :file => "#{Rails.root}/public/404.html",  layout: false, status: :not_found
	end

	def default_meta_description
		"In a post-truth world, thoughtful analysis has never been more necessary. And at TheArticle, we provide it by funding journalism for informed debate"
	end
	helper_method	:default_meta_description

	def default_page_title
		"Funding journalism for informed debate"
	end
	helper_method	:default_page_title

	def is_development?
		Rails.env == 'development'
	end
	helper_method	:is_development?

	def is_staging?
		Rails.env == 'staging'
	end
	helper_method	:is_staging?

	def show_ads?
		if is_development? || is_staging?
			false
		elsif self.class == ProfileWizardController
			false
		else
			true
		end
	end
	helper_method	:show_ads?

	def is_profile_page?
		self.class == UsersController && params[:action] == 'show'
	end
	helper_method	:is_profile_page?

	def is_article_page?
		ad_page_type == 'article'
	end
	helper_method	:is_article_page?

	def is_tablet?
		browser.device.tablet?
	end
	helper_method	:is_tablet?

	def articles_per_page
		browser.device.mobile? ? 3 : 6
	end
	helper_method	:articles_per_page

	def ad_page_type
		@ad_page_type ||= 'ros'
	end
	helper_method	:ad_page_type

	def ad_page_id
		if is_article_page?
			1540285666748
		elsif ad_page_type == 'homepage'
			1540285666750
		else
			1540285666762
		end
	end
	helper_method	:ad_page_id

	def article_carousel_sponsored_position
		if browser.device.mobile?
			3
		elsif browser.device.tablet?
			1
		else
			2
		end
	end

	def is_testing_environment?
		request.host.include?('localhost') || request.host.include?('live.thearticle.com')
	end
	helper_method	:is_testing_environment?


protected

	def after_sign_out_path_for(resource_or_scope)
    "#{root_path}?signed_out=1"
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || front_page_path
  end

  def configure_permitted_parameters
    added_attrs = [:username, :email, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  def json_request?
    request.format.json?
  end

private
  def set_device_type
    if browser.device.mobile?
      request.variant = :mobile
    else
      request.variant = :desktop
    end
  end

  def set_vary_header
  	response.headers["Vary"] = "Accept"
  end

	def set_layout
		user_signed_in? && browser.device.mobile? ? 'member' : 'application'
	end

	def profile_wizard_layout_for_mobile
		browser.device.mobile? ? 'profile-wizard' : 'application'
	end

	def authenticate_user!
		super
		if !current_user.has_completed_wizard? && request.format != 'application/json'
			if browser.device.mobile?
				redirect_to profile_wizard_path unless self.class == ProfileWizardController
			else
				redirect_to "/?force_home=1" unless self.class == HomeController
			end
		end
	end
end
