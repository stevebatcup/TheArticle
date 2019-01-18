module ExchangeHelper
	def exchange_excerpt(exchange, cutoff)
		if exchange.description
			exchange.description.truncate_words(cutoff)
		else
			''
		end
	end

	def subscription_list_as_json_data(user, subscriptions)
		list = []
	  subscriptions.each do |subscription|
	    list << subscription_item_as_json_data(user, subscription)
	  end
	  list
	end

	def subscription_item_as_json_data(user, subscription)
		exchange = subscription.exchange
		{
			type: 'exchange',
			stamp: subscription.created_at.to_i,
			id: exchange.id,
			path: exchange_path(slug: exchange.slug),
			img: exchange.image.url(:detail),
			image: exchange.image.url(:detail),
			name: exchange.name,
			slug: exchange.slug,
			excerpt: exchange_excerpt(exchange, browser.device.mobile? ? 9 : 20),
			blurb: exchange_excerpt(exchange, 10),
			imFollowing: user_signed_in? ? exchange.is_followed_by(user) : false,
			followedDate: subscription.created_at.strftime("%e %b"),
			user: {
			  path: profile_path(slug: user.slug),
			  id: user.id,
				isMuted: current_user.has_muted(user),
				isBlocked: current_user.has_blocked(user),
			  displayName: user.display_name,
			  username: user.username,
			  image: user.profile_photo.url(:square),
			}
		}
	end
end
