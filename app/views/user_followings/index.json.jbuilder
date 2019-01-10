json.set! :followers do
	json.array! @userFollowers do |follower|
		json.id follower.id
		json.displayName follower.display_name
		json.username follower.username
		json.bio bio_excerpt(follower, browser.device.mobile? ? 18 : 28)
		json.profilePhoto follower.profile_photo.url(:square)
		json.coverPhoto follower.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
		json.imFollowing user_signed_in? ? follower.is_followed_by(current_user) : false
		json.isFollowingMe user_signed_in? ? current_user.is_followed_by(follower) : false
	end
end

json.set! :followings do
	json.array! @userFollowings do |following|
		json.id following.id
		json.displayName following.display_name
		json.username following.username
		json.bio bio_excerpt(following, browser.device.mobile? ? 18 : 28)
		json.profilePhoto following.profile_photo.url(:square)
		json.coverPhoto following.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
		json.imFollowing user_signed_in? ? following.is_followed_by(current_user) : false
		json.isFollowingMe user_signed_in? ? current_user.is_followed_by(following) : false
	end
end
