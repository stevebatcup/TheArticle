commenters = []
if @commenters.any?
	@commenters.each do |commenter|
		commenters << {
			id: commenter.id,
			path: profile_path(slug: commenter.slug),
			displayName: commenter.display_name,
			username: commenter.username,
			image: commenter.profile_photo.url(:square)
		}
	end
end
json.commenters commenters