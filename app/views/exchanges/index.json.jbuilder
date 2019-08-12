json.set! :exchanges do
	json.array! @exchanges do |exchange|
		json.id exchange.id
		json.name exchange.name
		json.slug exchange.slug
		json.description exchange.description
		json.image exchange.image.url(:listing)
	end
end
json.mode @mode