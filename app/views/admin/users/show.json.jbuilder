json.id @user.id

if @full_details
	json.fullDetailsLoaded true
	json.lastIpAddress @user.last_sign_in_ip
	json.profileUrl "#{profile_url(slug: @user.slug)}?from_admin=1"
	json.lastSignIn @user.last_sign_in_at.present? ? @user.last_sign_in_at.strftime("%b %e, %Y at %H:%m") : nil
	json.verified @user.has_completed_wizard?
	json.blacklisted @user.is_blacklisted?
	json.watchlisted @user.is_watchlisted?
	json.isContributor @user.is_author?
	json.signupIpAddress @user.signup_ip_address
	json.signupLocation "#{@user.signup_ip_city}, #{@user.signup_ip_region}, #{@user.signup_ip_country}"
	json.profilePhoto @user.profile_photo.url(:square)
	json.coverPhoto @user.cover_photo.url(:desktop)
	json.notificationSettings do
		json.followers @user.notification_settings.find_by(key: :email_followers).value
		json.categorisations @user.notification_settings.find_by(key: :email_exchanges).value
		json.weeklyNewsletter @user.opted_into_weekly_newsletters?
		json.offers @user.opted_into_offers?
	end
else
	json.fullDetailsLoaded = false
	json.firstName @user.first_name
	json.lastName @user.last_name
	json.name @user.full_name.html_safe
	json.displayName @user.display_name.html_safe
	json.username @user.username
	json.email @user.email
	json.slug @user.slug
	json.signedUp @user.human_created_at
	json.accountStatus @user.admin_account_status
	json.profileStatus @user.admin_profile_status
end