json.status @status
json.redirect_to @redirect_to if @redirect_to
json.message @message if @message

if @status == :success
	json.set! :user do
		json.id @user.id
		json.displayName @user.default_display_name
		json.username @user.generate_usernames.shuffle.first
	end
end
