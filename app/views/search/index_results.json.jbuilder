items = []
begin
	@results.each do |result|
		if result.class == Article
			item = {
				type: :articles,
				id: result.id,
				image: result.image.url(:listing_mobile),
				title: strip_tags(result.title),
				path: article_path(result),
				publishedAt: article_date(result),
				author: {
					path: contributor_path(slug: result.author.slug),
					name: result.author.display_name
				}
			}
			if exchange = result.exchanges.first
				item[:exchange] = {
					name: exchange.name,
					path: exchange_path(slug: exchange.slug),
					isSponsored: exchange.slug == 'sponsored',
					slug: exchange.slug
				}
			end
			items << item

		elsif result.class == Author
			unless result.is_sponsor? || result.article_count < 1
				items << {
					type: :contributors,
					id: result.id,
					name: result.display_name.html_safe,
					image: result.image.url(:detail),
					articleCount: pluralize(result.article_count, "article"),
					path: contributor_path(slug: result.slug)
				}
			end

		elsif result.class == User
			items << {
				type: :profiles,
				id: result.id,
				path: profile_path(slug: result.slug),
				displayName: result.display_name.html_safe,
				username: result.username,
				bio: bio_excerpt(result, browser.device.mobile? ? 18 : 28),
				profilePhoto: result.profile_photo.url(:square),
				coverPhoto: result.cover_photo.url(:mobile),
				imFollowing: user_signed_in? ? result.is_followed_by(current_user) : false,
				isFollowingMe: user_signed_in? ? current_user.is_followed_by(result) : false,
				isBlocked: user_signed_in? ? current_user.has_blocked(result) : false,
				isBlockingMe: user_signed_in? ? result.has_blocked(current_user) : false,
				sharedFollowers: user_signed_in? ? generate_shared_followers_sentence(current_user, result) : false
			}

		elsif result.class == Exchange
			if result.slug != 'sponsored'
				items << {
					type: :exchanges,
					id: result.id,
					name: result.name.html_safe,
					image: result.image.url(:listing),
					imFollowing: user_signed_in? ? result.is_followed_by(current_user) : false,
					path: exchange_path(slug: result.slug)
				}
			end

		elsif result.class == Share
			item = share_as_json_data(result.user, result)
			item[:type] = :posts
			items << item
		end
	end

	json.results items

	if browser.device.mobile?
		if @latest_articles && @latest_articles.any?
			json.set! :latestArticles do
				json.array! @latest_articles do |article|
					json.id article.id
					json.title strip_tags(article.title)
					json.excerpt article_excerpt_for_listing(article).html_safe
					json.path article_path(article)
					json.isNew article.is_newly_published?
					json.publishedAt article_date(article)
					json.image article.image.url(:cover_mobile) if article.image?
					json.isSponsored article.is_sponsored
					json.author do
						author = article.author
						json.name author.display_name.html_safe
						json.path contributor_path(slug: author.slug)
					end
					json.exchanges article.exchanges do |exchange|
						json.slug exchange.slug
						json.path exchange_badge_url(exchange)
						json.isSponsored false
						json.name exchange.name
					end
				end
			end
		end
	end

rescue Exception => e
	json.results items
end