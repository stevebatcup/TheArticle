json.set! :opinions do
	json.set! :agrees do
		json.array! @share.agrees do |agree|
			json.set! :user do
				json.id agree.user.id
				json.path profile_path(slug: agree.user.slug)
				json.displayName agree.user.display_name
				json.username agree.user.username
				json.image agree.user.profile_photo.url(:square)
			end
		end
	end
	json.set! :disagrees do
		json.array! @share.disagrees do |disagree|
			json.set! :user do
				json.id disagree.user.id
				json.path profile_path(slug: disagree.user.slug)
				json.displayName disagree.user.display_name
				json.username disagree.user.username
				json.image disagree.user.profile_photo.url(:square)
			end
		end
	end
end
