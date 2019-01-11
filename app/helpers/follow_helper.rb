module FollowHelper
	def follow_as_json_data(user, follow)
		{
			type: 'follow',
			stamp: follow.created_at.to_i,
			date: follow.created_at.strftime("%e %b"),
			follower: {
				displayName: follow.user.display_name,
				username: follow.user.username,
				image: follow.user.profile_photo.url(:square)
			},
			followed: {
				displayName: follow.followed.display_name,
				username: follow.followed.username,
				image: follow.followed.profile_photo.url(:square)
			}
		}
	end
end