json.set! :exchanges do
	json.array! @userExchanges do |exchange|
		json.id exchange.id
		json.img exchange.image.url(:detail)
		json.name exchange.name
		json.slug exchange.slug
		json.excerpt exchange_excerpt(exchange, browser.device.mobile? ? 9 : 28)
	end
end