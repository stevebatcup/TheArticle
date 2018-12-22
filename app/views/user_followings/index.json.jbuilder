json.set! :followers do
	json.array! @userFollowers do |follower|
		json.id follower.id
		json.displayName follower.display_name
		json.username follower.username
		json.bio bio_excerpt(follower, browser.device.mobile? ? 18 : 28)
		json.profilePhoto follower.profile_photo.url(:square)
		json.coverPhoto follower.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
		json.imFollowing follower.is_followed_by(current_user)
		json.isFollowingMe current_user.is_followed_by(follower)
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
		json.imFollowing following.is_followed_by(current_user)
		json.isFollowingMe current_user.is_followed_by(following)
	end
end
