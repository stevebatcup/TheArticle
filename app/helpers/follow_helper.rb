module FollowHelper
	def follow_as_json_data(follow, current_user)
		{
			type: 'follow',
			stamp: follow.created_at.to_i,
			date: follow.created_at.strftime("%e %b"),
			follower: {
				id: follow.user.id,
				path: profile_path(slug: follow.user.slug),
				displayName: follow.user.display_name,
				username: follow.user.username,
				image: follow.user.profile_photo.url(:square)
			},
			followed: {
				displayName: current_user == follow.followed ? "You" : follow.followed.display_name,
				username: follow.followed.username,
				image: follow.followed.profile_photo.url(:square)
			}
		}
	end
end