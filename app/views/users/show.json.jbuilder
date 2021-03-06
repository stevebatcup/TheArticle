root_name = viewing_from_admin ? :admin_profile : :profile
json.set! root_name do
	json.isSignedIn user_signed_in?

	# basics
	json.id @user.id
	json.isNew true
	json.joinedAt	@user.created_at.strftime("%B %Y")

	# text
	displayName = @user.display_name
	json.displayName displayName

	fullUsername = @user.username
	json.username fullUsername[1..-1]
	json.originalUsername fullUsername

	json.location @user.location
	json.privateLocation @user.private_location
	json.bio @user.bio

	userPath = profile_path(slug: @user.slug)
	json.path userPath

	json.followingsCount @user.followings_count
	json.followersCount @user.followers_count
	if user_signed_in? && (current_user != @user)
		json.imFollowingCount current_user.im_following_same_count(@user)
	end
	json.connectionsCount @user.connections_count

	json.sharesCount @user.share_onlys.size
	json.ratingsCount @user.ratings_count

	# photos
	profileImage = @user.profile_photo.url(:square)
	json.profilePhoto do
		json.image profileImage
		json.source ""
		json.sourceForUpload ""
		json.uploading false
		json.width browser.device.mobile? ? 275 : 300
		json.height browser.device.mobile? ? 275 : 300
	end
	json.coverPhoto do
		json.image @user.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
		json.source ""
		json.sourceForUpload ""
		json.uploading false
		json.width browser.device.mobile? ? 330 : 570
		json.height browser.device.mobile? ? 66 : 114
	end

	recentFollowingSummary = following_summary(@user, @user.recent_followings(48))
	json.recentFollowingSummary do
		json.stamp recentFollowingSummary[:stamp]
		json.date recentFollowingSummary[:date]
		json.sentence recentFollowingSummary[:sentence].present? ? recentFollowingSummary[:sentence].html_safe : ''
		json.user do
			json.path userPath
			json.image profileImage
			json.displayName displayName
			json.username fullUsername
		end
	end

	recentFollowedSummary  = following_summary(@user, @user.recent_followeds(48), "followed")
	json.recentFollowedSummary do
		json.stamp recentFollowedSummary[:stamp]
		json.date recentFollowedSummary[:date]
		json.sentence recentFollowedSummary[:sentence].present? ? recentFollowedSummary[:sentence].html_safe : ''
		json.user do
			json.path userPath
			json.image profileImage
			json.displayName displayName
			json.username fullUsername
		end
	end

	json.set! :ratingsSummary do
		json.articleCount "#{pluralize(@user.ratings_summary[:article_count], 'rating')}"
		json.articleCountAsArticles "#{pluralize(@user.ratings_summary[:article_count], 'article')}"
		json.wellWritten readable_article_rating(@user.ratings_summary[:well_written])
		json.validPoints readable_article_rating(@user.ratings_summary[:valid_points])
		json.agree readable_article_rating(@user.ratings_summary[:agree])
	end

	json.imFollowing user_signed_in? && (current_user != @user) ? @user.is_followed_by(current_user) : false
	json.isFollowingMe user_signed_in? && (current_user != @user) ? current_user.is_followed_by(@user) : false
	json.isMuted user_signed_in? && (current_user != @user) ? current_user.has_muted(@user) : false

	json.isBlocked user_signed_in? && (current_user != @user) ? current_user.has_blocked(@user) : false
	json.iAmBlocked user_signed_in? && (current_user != @user) ? @user.has_blocked(current_user) : false

	json.isMe user_signed_in? ? @user == current_user : false

	json.deactivated @user.profile_is_deactivated?

	if @user.author
		json.author do
			json.articleCount @user.author.article_count
			json.articleCountSentence pluralize(@user.author.article_count, 'article')
			json.path contributor_path(slug: @user.author.slug)
		end
	else
		json.author false
	end
end