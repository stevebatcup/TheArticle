json.set! :profile do
	# basics
	json.id @user.id
	json.isNew true
	json.joinedAt	@user.created_at.strftime("%B %Y")

	# text
	json.displayName @user.display_name
	json.username @user.username[1..-1]
	json.originalUsername @user.username
	json.location @user.location
	json.bio @user.bio

	# follows
	json.imFollowing user_signed_in? ? @user.is_followed_by(current_user) : false
	json.set! :followers do
		json.array! @user.followers do |follower|
			json.id follower.id
			json.displayName follower.display_name
			json.username follower.username
			json.bio bio_excerpt(follower, browser.device.mobile? ? 9 : 28)
			json.profilePhoto follower.profile_photo.url(:square)
			json.coverPhoto follower.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
			json.imFollowing user_signed_in? ? follower.is_followed_by(current_user) : false
			json.isFollowingMe user_signed_in? ? current_user.is_followed_by(@user) : false
		end
	end

	json.set! :followings do
		json.array! @user.followings do |following|
			json.id following.followed_id
			json.displayName following.followed.display_name
			json.username following.followed.username
			json.bio bio_excerpt(following.followed, browser.device.mobile? ? 9 : 28)
			json.profilePhoto following.followed.profile_photo.url(:square)
			json.coverPhoto following.followed.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
			json.imFollowing user_signed_in? ? following.followed.is_followed_by(current_user) : false
			json.isFollowingMe user_signed_in? ? current_user.is_followed_by(@user) : false
		end
	end

	# other resource data
	json.shares 191
	json.ratings 3

	# photos
	json.profilePhoto do
		json.image @user.profile_photo.url(:square)
		json.source ""
	end
	json.coverPhoto do
		json.image @user.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
		json.source ""
	end
end