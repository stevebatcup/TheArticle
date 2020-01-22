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
			sleep(1)
		end
	end

	task :clean_followed, [:limit] => [:environment] do |t, args|
		limit = (args[:limit] || 5).to_i
		users  = User.where(suggestions_cleaned: false).limit(limit)
		puts "#{users.length} users found..."
		if users.any?
			users.each do |user|
				puts "Cleaning suggestions for user #{user.id}...."
				user.profile_suggestions.each do |suggestion|
					if Follow.find_by(user_id: suggestion.user_id, followed_id: suggestion.suggested_id)
						suggestion.follow
						puts "Archived suggestion ID #{suggestion.id}."
					else
						puts "ID #{suggestion.id} not followed."
					end
				end
				user.update_attribute(:suggestions_cleaned, true)
				puts "........"
			end
		end
	end
end
