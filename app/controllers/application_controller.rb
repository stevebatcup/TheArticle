class ApplicationController < ActionController::Base
	before_action :set_device_type

	def not_found
	  raise ActionController::RoutingError.new('Not Found')
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
		!is_development?
	end
	helper_method	:show_ads?

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

private
  def set_device_type
    if browser.device.mobile?
      request.variant = :mobile
    else
      request.variant = :desktop
    end
  end

	def set_layout
		user_signed_in? ? 'member' : 'application'
	end

	def authenticate_user!
		super
		redirect_to new_profile_path unless current_user.has_completed_wizard? || self.class == ProfileWizardController
	end
end
