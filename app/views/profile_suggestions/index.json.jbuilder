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
				json.sharedFollowers suggestion.shared_followers_sentence

				json.set! :extraInfo do
					json.followerCount pluralize(user.followers_count, 'follower') if user.followers_count > 0
					json.ratingsCount pluralize(user.ratings_count, 'rating') if user.ratings_count > 0
					json.publishedArticlesCount pluralize(user.author.article_count, 'published article') if user.is_author? && user.author.article_count > 0
				end
			end
		end
	end

	if @populars
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
				json.sharedFollowers suggestion.shared_followers_sentence

				json.set! :extraInfo do
					json.followerCount pluralize(user.followers_count, 'follower') if user.followers_count > 0
					json.ratingsCount pluralize(user.ratings_count, 'rating') if user.ratings_count > 0
					json.publishedArticlesCount pluralize(user.author.article_count, 'published article') if user.is_author? && user.author.article_count > 0
				end
			end
		end
	end

	if @bibblio_results
		json.populars []
		json.set! :forYous do
			json.array! @bibblio_results do |user|
				# if user_signed_in?
				# 	suggestion = current_user.profile_suggestions.find_by(suggested_id: user.id)
				# else
				# 	suggestion = nil
				# end
				json.reason "Bibblio recommendation"
				json.id user.id
				json.path profile_path(slug: user.slug)
				json.displayName user.display_name
				json.username user.username
				json.bio bio_excerpt(user, browser.device.mobile? ? 18 : 28)
				json.profilePhoto user.profile_photo.url(:square)
				json.coverPhoto user.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
				json.imFollowing user.is_followed_by(current_user)
				json.isFollowingMe current_user.is_followed_by(user)
				# json.sharedFollowers user_signed_in? && suggestion.present? ? suggestion.shared_followers_sentence : false
			end
		end
	end

	if @search_results
		json.set! :searchResults do
			json.array! @search_results do |user|
				if user_signed_in?
					suggestion = current_user.profile_suggestions.find_by(suggested_id: user.id)
				else
					suggestion = nil
				end
				json.id user.id
				json.path @from_wizard ? '#' : profile_path(slug: user.slug)
				json.displayName user.display_name
				json.username user.username
				json.bio bio_excerpt(user, browser.device.mobile? ? 18 : 28)
				json.profilePhoto user.profile_photo.url(:square)
				json.coverPhoto user.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
				json.imFollowing user.is_followed_by(current_user)
				json.isFollowingMe current_user.is_followed_by(user)
				json.sharedFollowers user_signed_in? && suggestion.present? ? suggestion.shared_followers_sentence : false
			end
		end
	end

end