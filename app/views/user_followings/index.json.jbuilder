json.total @total if @total

json.set! :list do
	json.set! :followers do
		json.array! @userFollowers do |follower|
			json.id follower.id
			json.path profile_path(slug: follower.slug)
			json.authorPath contributor_path(slug: follower.author.slug) if follower.is_author?
			json.displayName follower.display_name
			json.username follower.username
			json.bio bio_excerpt(follower, browser.device.mobile? ? 18 : 28)
			json.profilePhoto follower.profile_photo.url(:square)
			json.coverPhoto follower.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)

			im_following = user_signed_in? ? follower.is_followed_by(current_user) : false
			json.imFollowing im_following

			is_following_me = user_signed_in? ? current_user.is_followed_by(follower) : false
			json.isFollowingMe is_following_me

			json.isConnected im_following && is_following_me
			json.isMe user_signed_in? ? follower == current_user : false

			json.set! :extraInfo do
				json.followerCount pluralize(follower.followers_count, 'follower') if follower.followers_count > 0
				json.ratingsCount pluralize(follower.ratings_count, 'rating') if follower.ratings_count > 0
				json.publishedArticlesCount pluralize(follower.author.article_count, 'published article') if follower.is_author? && follower.author.article_count > 0
			end
		end
	end

	json.set! :followings do
		json.array! @userFollowings do |following|
			json.id following.id
			json.path profile_path(slug: following.slug)
			json.authorPath contributor_path(slug: following.author.slug) if following.is_author?
			json.displayName following.display_name
			json.username following.username
			json.bio bio_excerpt(following, browser.device.mobile? ? 18 : 28)
			json.profilePhoto following.profile_photo.url(:square)
			json.coverPhoto following.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)

			im_following = user_signed_in? ? following.is_followed_by(current_user) : false
			json.imFollowing im_following

			is_following_me = user_signed_in? ? current_user.is_followed_by(following) : false
			json.isFollowingMe is_following_me

			json.isConnected im_following && is_following_me
			json.isMe user_signed_in? ? following == current_user : false

			json.set! :extraInfo do
				json.followerCount pluralize(following.followers_count, 'follower') if following.followers_count > 0
				json.ratingsCount pluralize(following.ratings_count, 'rating') if following.ratings_count > 0
				json.publishedArticlesCount pluralize(following.author.article_count, 'published article') if following.is_author? && following.author.article_count > 0
			end
		end
	end
end