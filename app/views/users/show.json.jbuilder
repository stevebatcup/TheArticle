json.set! :profile do
	json.id @user.id
	json.displayName @user.display_name
	json.username @user.username[1..-1]
	json.originalUsername @user.username
	json.ratings 3
	json.followers 6
	json.following 98
	json.shares 191
	json.exchanges 67
	json.location @user.location
	json.bio @user.bio
	json.profilePhoto @user.profile_photo.url(:square)
	json.isNew true
	json.joinedAt	@user.created_at.strftime("%B %Y")
end