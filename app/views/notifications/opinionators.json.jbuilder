opinionators = []
if @opinionators.any?
	@opinionators.each do |opinionator|
		opinionators << {
			id: opinionator.id,
			path: profile_path(slug: opinionator.slug),
			displayName: opinionator.display_name,
			username: opinionator.username,
			image: opinionator.profile_photo.url(:square)
		}
	end
end
json.opinionators opinionators