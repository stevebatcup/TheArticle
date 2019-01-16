json.set! :followers do
	json.array! @follow_group.follows do |follow|
		user = follow.user
		json.id user.id
		json.path profile_path(slug: user.slug)
		json.displayName user.display_name
		json.username user.username
		json.bio bio_excerpt(user, browser.device.mobile? ? 9 : 28)
		json.profilePhoto user.profile_photo.url(:square)
		json.coverPhoto user.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
		json.imFollowing user_signed_in? ? user.is_followed_by(current_user) : false
		json.isFollowingMe user_signed_in? ? current_user.is_followed_by(user) : false
	end
end