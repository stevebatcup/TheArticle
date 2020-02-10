namespace :suggestions do
	task dedupe: :environment do
		dupes = ProfileSuggestion.select("COUNT(*) AS item_count, user_id, suggested_id")
											.group("user_id, suggested_id")
											.having("item_count > 1")
											.order(id: :desc)
											.limit(500)
											.to_a
		if dupes.any?
			dupes.each do |dupe|
				if item = ProfileSuggestion.find_by(user_id: dupe.user_id, suggested_id: dupe.suggested_id, status: 0)
					item.destroy
					sleep(1)
				end
			end
		end
	end

	task archive_expired: :environment do
		User.order(id: :desc).all.each do |user|
			ProfileSuggestion.archive_expired_for_user(user)
		end
	end
end
