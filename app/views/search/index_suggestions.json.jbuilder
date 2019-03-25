begin
	# Has Query
	if @topics.any?
		json.set! :topics do
			json.array! @topics do |topic|
				json.term topic.name
				json.articleCount pluralize(topic.articles.size, "article")
				json.path search_path(query: topic.slug)
			end
		end
	end

	if @exchanges.any?
		json.set! :exchanges do
			json.array! @exchanges do |exchange|
				json.term exchange.name
				json.image exchange.image.url(:listing)
				json.path exchange_path(slug: exchange.slug)
			end
		end
	end

	if @contributors.any?
		json.set! :contributors do
			json.array! @contributors do |contributor|
				unless contributor.is_sponsor?
					json.term contributor.display_name.html_safe
					json.image contributor.image.url(:listing)
					json.articleCount pluralize(contributor.articles.size, "article")
					json.path contributor_path(slug: contributor.slug)
				end
			end
		end
	end

	if @profiles.any?
		json.set! :profiles do
			json.array! @profiles do |user|
				json.term user.display_name.html_safe
				json.image user.profile_photo.url(:square)
				json.username user.username
				json.followingSentence user_signed_in? && user.is_followed_by(current_user) ? "Following" : pluralize(user.followers.size, "follower")
				json.path profile_path(slug: user.slug)
			end
		end
	end

	# No Query
	if @recent_searches.any?
		json.set! :recentSearches do
			json.array! @recent_searches do |search_term|
				json.term search_term
				json.path search_path(query: search_term)
			end
		end
	end

	if @who_to_follow.any?
		json.profileMode @profile_suggestions_mode
		json.set! :whoToFollow do
			json.array! @who_to_follow do |user|
				json.term user.display_name.html_safe
				json.path profile_path(slug: user.slug)
			end
		end
	end

	if @trending_articles.any?
		json.set! :trendingArticles do
			json.array! @trending_articles do |article|
				json.term article.title.html_safe
				json.path article_path(article)
			end
		end
	end

	if @trending_exchanges.any?
		json.set! :trendingExchanges do
			json.array! @trending_exchanges do |exchange|
				json.term exchange.name
				json.path exchange_path(slug: exchange.slug)
			end
		end
	end
rescue Exception => e
end