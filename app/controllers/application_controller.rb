class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: "londonbridge", password: "B37ys0m2w" if Rails.env == 'staging'
  # http_basic_authenticate_with name: "borehamwood", password: "N5T0d341Vh" if Rails.env == 'production'
	before_action :set_device_type
	before_action :prepare_exception_notifier
  protect_from_forgery with: :exception, if: Proc.new { |c| c.request.format != 'application/json' }
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  skip_before_action :verify_authenticity_token, if: :json_request?
  before_action :set_vary_header
  before_action :configure_permitted_parameters, if: :devise_controller?

	def show_ads?
		if viewing_from_admin
			false
		elsif is_development?
			false
		elsif is_staging?
			true
		elsif self.class == ProfileWizardController
			false
		else
			true
		end
	end
	helper_method	:show_ads?

	def not_found
	  raise ActionController::RoutingError.new('Not Found')
	end

	def render_404
		render :file => "#{Rails.root}/public/404.html",  layout: false, status: :not_found
	end

	def viewing_from_admin
		user_signed_in? && current_user.is_admin? && params[:from_admin].present?
	end
	helper_method	:viewing_from_admin

	def default_meta_description
		"Eclectic, enjoyable, essential reading. We are the only publisher that is also a social media platform so you get personalised debate with no pay wall."
	end
	helper_method	:default_meta_description

	def default_page_title
		"TheArticle. Every Angle."
	end
	helper_method	:default_page_title

	def is_development?
		Rails.env == 'development'
	end
	helper_method	:is_development?

	def is_staging?
		Rails.env.to_sym == :staging
	end
	helper_method	:is_staging?

	def hide_footer?
		false
	end
	helper_method	:hide_footer?

	def gtm_id
		'GTM-5ZWCFHN'
	end
	helper_method	:gtm_id

	def is_profile_page?
		self.class == UsersController && params[:action] == 'show'
	end
	helper_method	:is_profile_page?

	def is_article_page?
		(params[:controller].to_sym == :articles) and (params[:action].to_sym == :show)
	end
	helper_method	:is_article_page?

	def is_author_page?
		(params[:controller].to_sym == :contributors) and (params[:action].to_sym == :show)
	end
	helper_method	:is_author_page?

	def is_tablet?
		browser.device.tablet?
	end
	helper_method	:is_tablet?

	def articles_per_page
		browser.device.mobile? ? 15 : 15
	end
	helper_method	:articles_per_page

	def exchange_articles_per_page
		browser.device.mobile? ? 10 : 12
	end
	helper_method	:exchange_articles_per_page

	def more_on_articles_per_page
		browser.device.mobile? ? 10 : 6
	end
	helper_method	:more_on_articles_per_page

	def ad_page_type
		@ad_page_type ||= begin
			if is_article_page?
				'article'
			elsif (params[:controller].to_sym == :home) and (params[:action].to_sym == :index)
				'homepage'
			else
				'ros'
			end
		end
	end
	helper_method	:ad_page_type

	def ad_publisher_id
		@ad_publisher_id ||= 21757645549 #89927887
	end
	helper_method	:ad_publisher_id

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
		request.host.include?('live.thearticle.com')
	end
	helper_method	:is_testing_environment?

	def device_type_for_events
		@device_type_for_events ||= begin
			if browser.device.tablet?
				'tablet'
			elsif browser.device.mobile?
				'mobile'
			else
				'desktop'
			end
		end
	end
	helper_method	:device_type_for_events

	def page_requires_tinymce?
		user_signed_in?
	end
	helper_method	:page_requires_tinymce?

	def page_requires_google_maps?
		user_signed_in?
	end
	helper_method	:page_requires_google_maps?

	def better_model_error_messages(resource)
		messages = resource.errors.details.keys.map do |attr|
			resource.errors.full_messages_for(attr).first
		end
		messages.join
	end

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
    if browser.device.mobile? || request.headers["X-MobileApp"] || params[:forcemobile].present?
      request.variant = :mobile
    elsif browser.device.tablet?
      request.variant = :tablet
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

	def authenticate_basic_user
		unless user_signed_in?
			redirect_to "/?force_home=1"
		end
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

	def prepare_exception_notifier
		ActiveRecord::Base.logger.silence do
	    request.env["exception_notifier.exception_data"] = {
	      current_user: user_signed_in? ? current_user : nil,
	      browser: browser.to_s,
	      device: browser.device.name,
	      platform: browser.platform.name
	    }
	  end
  end
end
