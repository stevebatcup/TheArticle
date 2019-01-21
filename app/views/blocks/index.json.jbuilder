json.set! :blocks do
	json.array! @blocks do |block|
		user = block.blocked
		json.id user.id
		json.path profile_path(slug: user.slug)
		json.displayName user.display_name
		json.username user.username
		json.profilePhoto user.profile_photo.url(:square)
		json.coverPhoto user.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
		json.isBlock true
	end
end