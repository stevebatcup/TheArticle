json.set! :profile do
	json.displayName @user.display_name
	json.username @user.username
	json.ratings 3
	json.followers 6
	json.following 98
	json.location @user.location
	json.bio @user.bio
	json.isNew true
	json.joinedAt	@user.created_at.strftime("%B %Y")
end