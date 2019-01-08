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
				json.excerpt exchange_excerpt(result, 10)
				json.imFollowing user_signed_in? ? result.is_followed_by(current_user) : false
				json.path exchange_path(slug: result.slug)
			elsif result.class == Share
				json.type :posts
				json.set! :share do
					json.isRatings true
					json.date result.created_at.strftime("%e %b")
					json.commentCount pluralize(result.commentCount, 'comment')
					json.agreeCount "#{pluralize(result.agreeCount, 'person')} agree"
					json.disagreeCount "#{pluralize(result.disagreeCount, 'person')} disagree"
					json.comments result.comments
				end
				json.set! :ratings do
					json.wellWritten result.rating_well_written
					json.validPoints result.rating_valid_points
					json.agree result.rating_agree
				end
				json.set! :user do
					json.displayName result.user.display_name
					json.username result.user.username
					json.image result.user.profile_photo.url(:square)
				end
				json.set! :article do
					json.id result.article.id
					json.snippet article_excerpt_for_listing(result.article, 160)
					json.image result.article.image.url(:cover_mobile)
					json.title strip_tags(result.article.title)
					json.publishedAt article_date(result.article)
					json.path article_path(result.article)
					json.set! :author do
						author = result.article.author
					  json.name author.display_name
					  json.path contributor_path(slug: author.slug)
					end
					exchange = result.article.exchanges.first
					json.set! :exchange do
						json.name exchange.name
						json.path exchange_path(slug: exchange.slug)
						json.isSponsored exchange.slug == 'sponsored'
						json.slug exchange.slug
					end
				end
			end
		end
	end
end
