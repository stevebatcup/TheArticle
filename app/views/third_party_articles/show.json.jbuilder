json.status @status
json.message @message if @message

if @articleOG
	json.set! :article do
		json.title @articleOG.title.encode('utf-8', invalid: :replace, undef: :replace, replace: '')
		json.type @articleOG.type
		image_url = @articleOG.image.url
		json.image image_url.slice(0, image_url.index("?"))
		json.image image_url
		json.url @articleOG.url
		json.siteName @articleOG.site_name
		description = @articleOG.description.encode('utf-8', invalid: :replace, undef: :replace, replace: '')
		json.snippet truncate(description, length: 150)
	end
end