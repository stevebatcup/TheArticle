json.followed @followed.display_name
followers = []
if @followers.any?
	@followers.each do |follower|
		followers << {
			id: follower.id,
			path: profile_path(slug: follower.slug),
			displayName: follower.display_name,
			username: follower.username,
			image: follower.profile_photo.url(:square)
		}
	end
end
json.followers followers