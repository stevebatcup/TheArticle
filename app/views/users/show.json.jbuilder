json.set! :profile do
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
	json.bio @user.bio

	userPath = profile_path(slug: @user.slug)
	json.path userPath

	# photos
	profileImage = @user.profile_photo.url(:square)
	json.profilePhoto do
		json.image profileImage
		json.source ""
		json.sourceForUpload ""
		json.uploading false
	end
	json.coverPhoto do
		json.image @user.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
		json.source ""
		json.sourceForUpload ""
		json.uploading false
	end

	recentFollowingSummary = following_summary(@user.recent_followings(48))
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

	recentFollowedSummary  = following_summary(@user.recent_followeds(48), "followed")
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
		json.articleCount "#{pluralize(@user.ratingsSummary[:article_count], 'article')} rated"
		json.wellWritten @user.ratingsSummary[:well_written]
		json.validPoints @user.ratingsSummary[:valid_points]
		json.agree @user.ratingsSummary[:agree]
	end

	json.imFollowing user_signed_in? && (current_user != @user) ? @user.is_followed_by(current_user) : false
	json.isMuted user_signed_in? && (current_user != @user) ? current_user.has_muted(@user) : false

	json.isBlocked user_signed_in? && (current_user != @user) ? current_user.has_blocked(@user) : false
	json.iAmBlocked user_signed_in? && (current_user != @user) ? @user.has_blocked(current_user) : false

	json.isMe user_signed_in? ? @user == current_user : false
end