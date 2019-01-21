json.set! :connects do
	json.array! @connects do |user|
		json.id user.id
		json.path profile_path(slug: user.slug)
		json.displayName user.display_name
		json.username user.username
		json.profilePhoto user.profile_photo.url(:square)
		json.coverPhoto user.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
		json.imFollowing true
	end
end