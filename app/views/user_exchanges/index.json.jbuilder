json.set! :exchanges do
	json.array! @userExchanges do |subscription|
		exchange = subscription.exchange
		json.stamp subscription.created_at.to_i
		json.id exchange.id
		json.img exchange.image.url(:detail)
		json.image exchange.image.url(:detail)
		json.name exchange.name
		json.slug exchange.slug
		json.excerpt exchange_excerpt(exchange, browser.device.mobile? ? 9 : 20)
		json.blurb exchange_excerpt(exchange, 10)
		json.imFollowing user_signed_in? ? exchange.is_followed_by(@user) : false
		json.followedDate subscription.created_at.strftime("%e %b")
		json.set! :user do
			json.displayName @user.display_name
			json.username @user.username
			json.image @user.profile_photo.url(:square)
		end
	end
end