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
		bclasses << 'show_cookie_notice' unless (cookies[:cookie_permission_set] || request.headers["X-MobileApp"])
		bclasses << 'tablet' if browser.device.tablet?
    bclasses << 'show_ads' if show_ads?
    bclasses << 'show_video_ads_only' if show_video_ads_only?
    if is_testing_environment?
      unless cookies[:cookie_test_environment_seen]
        bclasses << 'show_testing_interstitial'
      end
    end
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

  def happened_at(date)
  	val = (Time.now.to_i - date.to_i)
    if date > 1.minute.ago
      "less than a minute ago"
  	elsif date > 1.hour.ago
  		"#{val/60}m ago"
  	elsif date > 1.day.ago
  		"#{pluralize(val/60/60, 'hour')} ago"
  	elsif date > 1.week.ago
  		"#{pluralize(val/60/60/24, 'day')} ago"
  	elsif date > 4.weeks.ago
  		"#{pluralize(val/60/60/24/7, 'week')} ago"
  	else
  		"a while ago"
  	end
  end

  def pluralize_without_count(count, noun, text = nil)
    if count != 0
      count == 1 ? "#{noun}#{text}" : "#{noun.pluralize}#{text}"
    end
  end

  def nanospell_url
    if Rails.env.development?
      "http://admin.thearticle.jazz/nanospell/server/ajax/php/tinyspell.php"
    else
      "https://office.thearticle.com/nanospell/server/ajax/php/tinyspell.php"
    end
  end

  def event_date_formatted(date)
    if date.year < Date.today.year
      date.strftime("%e %b, %Y")
    else
      date.strftime("%e %b")
    end
  end
end
