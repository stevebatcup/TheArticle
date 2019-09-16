json.set! :authors do
	json.array! @authors do |author|
		json.id	author.id
		json.name author.display_name
	end
end