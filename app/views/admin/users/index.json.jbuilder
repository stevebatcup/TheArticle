json.totalPages @total_pages if @total_pages
json.totalRecords @total_records if @total_records
json.set! :users do
	json.array! @users do |user|
		json.id user.id
		json.firstName user.first_name
		json.lastName user.last_name
		json.name user.full_name.html_safe
		json.displayName user.display_name.html_safe
		json.username user.username
		json.email user.email
		json.slug user.slug
		json.blacklisted user.is_blacklisted?
		json.watchlisted user.is_watchlisted?
		json.confirmed user.has_completed_wizard?
		json.signedUp user.human_created_at
		json.profileUrl "#{profile_url(slug: user.slug)}?from_admin=1"
		json.accountStatus user.admin_account_status
		json.profileStatus user.admin_profile_status
		json.followersCount user.followers_count
		json.ratingsCount user.share_ratings_count
	end
end
