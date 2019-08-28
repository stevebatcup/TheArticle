json.set! :users do
	json.array! @users do |user|
		json.id user.id
		json.accountName user.full_name
		json.displayName user.display_name.html_safe
		json.username user.username
		json.email user.email
		json.slug user.slug
		json.blacklisted user.is_blacklisted?
		json.watchlisted user.is_watchlisted?
		json.confirmed user.has_completed_wizard?
		json.signedUp user.created_at.strftime("%Y")
		json.accountStatus user.admin_account_status
		json.profileStatus user.admin_profile_status
	end
end
