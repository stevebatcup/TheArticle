json.set! :suggestions do
	if @for_yous
		json.set! :forYous do
			json.array! @for_yous do |suggestion|
				json.reason suggestion.reason
				user = suggestion.suggested
				json.id user.id
				json.articleCount suggestion.author_article_count
				json.path profile_path(slug: user.slug)
				json.authorPath contributor_path(slug: user.author.slug) if user.is_author?
				json.displayName user.display_name
				json.username user.username
				json.bio bio_excerpt(user, browser.device.mobile? ? 18 : 23)
				json.profilePhoto user.profile_photo.url(:square)
				json.coverPhoto user.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
				json.imFollowing user.is_followed_by(current_user)
				json.isFollowingMe current_user.is_followed_by(user)
				json.sharedFollowers generate_shared_followers_sentence(current_user, user)

				json.set! :extraInfo do
					json.followerCount pluralize(user.followers_count, 'follower') if user.followers_count > 0
					json.ratingsCount pluralize(user.ratings_count, 'rating') if user.ratings_count > 0
					json.publishedArticlesCount pluralize(user.author.article_count, 'published article') if user.is_author? && user.author.article_count > 0
				end
			end
		end
	end

	if @populars && @populars.any?
		json.set! :populars do
			json.array! @populars do |suggestion|
				json.reason suggestion.reason
				user = suggestion.suggested
				json.id user.id
				json.path profile_path(slug: user.slug)
				json.displayName user.display_name
				json.username user.username
				json.bio bio_excerpt(user, browser.device.mobile? ? 18 : 23)
				json.profilePhoto user.profile_photo.url(:square)
				json.coverPhoto user.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
				json.imFollowing user.is_followed_by(current_user)
				json.isFollowingMe current_user.is_followed_by(user)
				json.sharedFollowers generate_shared_followers_sentence(current_user, user)

				json.set! :extraInfo do
					json.followerCount pluralize(user.followers_count, 'follower') if user.followers_count > 0
					json.ratingsCount pluralize(user.ratings_count, 'rating') if user.ratings_count > 0
					json.publishedArticlesCount pluralize(user.author.article_count, 'published article') if user.is_author? && user.author.article_count > 0
				end
			end
		end
	end

	if @search_results
		json.set! :searchResults do
			json.array! @search_results do |user|
				json.id user.id
				json.path @from_wizard ? '#' : profile_path(slug: user.slug)
				json.displayName user.display_name
				json.username user.username
				json.bio bio_excerpt(user, browser.device.mobile? ? 18 : 28)
				json.profilePhoto user.profile_photo.url(:square)
				json.coverPhoto user.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
				json.imFollowing user.is_followed_by(current_user)
				json.isFollowingMe current_user.is_followed_by(user)
				json.sharedFollowers generate_shared_followers_sentence(current_user, user)
			end
		end
	end

end