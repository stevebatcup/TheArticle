json.set! :authors do
	json.array! @authors do |author|
		json.id	author.id
		json.namail "#{author.display_name} (#{author.email})"
	end
end