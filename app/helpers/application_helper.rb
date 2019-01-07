module ApplicationHelper
	def ga_tracking_id
		Rails.application.credentials.ga_tracking_id[Rails.env.to_sym]
	end

	def exchange_badge_url(exchange)
		exchange.slug == 'sponsored' ? '/sponsors' : exchange_path(slug: exchange.slug)
	end

	def strip_protocol(url)
		url.sub('https://','').sub('http://','')
	end

	def body_classes
		bclasses = [Rails.env]
		bclasses << 'show_cookie_notice' unless cookies[:cookie_permission_set]
		bclasses << 'tablet' if browser.device.tablet?
		bclasses.join(" ")
	end

	def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
		@devise_mapping ||= Devise.mappings[:user]
  end
end
