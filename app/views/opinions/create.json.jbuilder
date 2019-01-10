json.status @status
json.set! :user do
	json.id @user.id
	json.displayName @user.display_name
	json.username @user.username
	json.image @user.profile_photo.url(:square)
end