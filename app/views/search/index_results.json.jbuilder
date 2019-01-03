if @results.any?
	json.set! :results do
		json.array! @results do |result|
			# json.className result.class.to_s
			if result.class == Article
				json.type :articles
				json.id result.id
				json.author result.author.display_name
				json.snippet article_excerpt_for_listing(result, 120)
				json.image result.image.url(:listing_mobile)
				json.title strip_tags(result.title)
				json.path article_path(result)
			elsif result.class == Author
				json.type :contributors
				json.id result.id
				json.name result.display_name.html_safe
				json.image result.image.url(:detail)
				json.articleCount pluralize(result.article_count, "article")
				json.path contributor_path(slug: result.slug)
			elsif result.class == User
				json.type :profiles
				json.id result.id
				json.displayName result.display_name.html_safe
				json.username result.username
				json.bio bio_excerpt(result, browser.device.mobile? ? 18 : 28)
				json.profilePhoto result.profile_photo.url(:square)
				json.imFollowing user_signed_in? ? result.is_followed_by(current_user) : false
				json.isFollowingMe user_signed_in? ? current_user.is_followed_by(result) : false
				json.path profile_path(slug: result.slug)
			elsif result.class == Exchange
				json.type :exchanges
				json.id result.id
				json.name result.name.html_safe
				json.image result.image.url(:detail)
				json.blurb exchange_excerpt(result, 10)
				json.imFollowing user_signed_in? ? result.is_followed_by(current_user) : false
				json.path exchange_path(slug: result.slug)
			end
		end
	end
end
