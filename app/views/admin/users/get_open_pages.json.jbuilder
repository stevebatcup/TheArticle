json.set! :pages do
	json.array! @pages do |page|
		json.id page["id"]
		json.name page["name"]
	end
end
