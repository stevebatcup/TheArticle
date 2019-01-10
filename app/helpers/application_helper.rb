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

  def comment_for_tpl(comment)
  	{
  		id: comment.id,
      path: profile_path(slug: comment.user.slug),
      displayName: comment.user.display_name,
  		username: comment.user.username,
  		photo: comment.user.profile_photo.url(:square),
  		body: simple_format(comment.body),
  		timeActual: comment.created_at.strftime("%Y-%m-%d %H:%M"),
  		timeHuman: comment.created_at.strftime("%e %b"),
      replyShowLimit: Comment.show_reply_limit
  	}
  end
end
