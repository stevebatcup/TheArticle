json.set! :suggestions do
	json.set! :forYous do
		json.array! @for_yous do |suggestion|
			json.reason suggestion.reason
			user = suggestion.suggested
			json.id user.id
			json.displayName user.display_name
			json.username user.username
			json.bio bio_excerpt(user, browser.device.mobile? ? 18 : 28)
			json.profilePhoto user.profile_photo.url(:square)
			json.coverPhoto user.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
			json.imFollowing user.is_followed_by(current_user)
			json.isFollowingMe current_user.is_followed_by(user)
		end
	end

	json.set! :populars do
		json.array! @populars do |suggestion|
			json.reason suggestion.reason
			user = suggestion.suggested
			json.id user.id
			json.displayName user.display_name
			json.username user.username
			json.bio bio_excerpt(user, browser.device.mobile? ? 18 : 28)
			json.profilePhoto user.profile_photo.url(:square)
			json.coverPhoto user.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
			json.imFollowing user.is_followed_by(current_user)
			json.isFollowingMe current_user.is_followed_by(user)
		end
	end
end