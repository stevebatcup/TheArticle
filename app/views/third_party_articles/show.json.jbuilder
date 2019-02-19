json.status @status
json.message @message if @message

if @articleOG
	json.set! :article do
		title = sanitize(@articleOG.title.encode('utf-8', invalid: :replace, undef: :replace, replace: ''))
		json.title truncate(title, length: 180)
		if title.length > 120
			description_length = 0
		elsif title.length > 60
			description_length = 75
		else
			description_length = 150
		end
		if description_length > 0
			description = @articleOG.description.encode('utf-8', invalid: :replace, undef: :replace, replace: '')
			json.snippet truncate(sanitize(description), length: description_length)
		else
			json.snippet ''
		end
		json.type @articleOG.type
		image_url = @articleOG.image.url
		json.image image_url.include?("?") ? image_url.slice(0, image_url.index("?")) : image_url
		json.image image_url
		json.url @articleOG.url
		json.domain ThirdPartyArticleService.get_domain_from_url(@articleOG.url)
		json.siteName @articleOG.site_name
	end
end