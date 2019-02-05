json.set! :suggestions do
	if @suggestions.any?
		json.set! :forYous do
			json.array! @suggestions do |user|
				json.id user.id
				json.path '#'
				json.displayName user.display_name
				json.username user.username
				json.bio bio_excerpt(user, browser.device.mobile? ? 18 : 23)
				json.profilePhoto user.profile_photo.url(:square)
				json.coverPhoto user.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
				json.imFollowing user.is_followed_by(current_user)
				json.isFollowingMe current_user.is_followed_by(user)
				json.sharedFollowers generate_shared_followers_sentence(current_user, user)
			end
		end
	end
end