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

	def subscription_item_as_json_data(user, subscription, sentence='', source_type='profile')
		exchange = subscription.exchange
		sentence = "<b>#{user.display_name}</b> <span class='text-muted'>#{user.username}</span> followed an exchange" if sentence.length == 0
		{
			type: 'exchange',
			sourceType: source_type,
			stamp: subscription.created_at.to_i,
			id: exchange.id,
			path: exchange_path(slug: exchange.slug),
			img: exchange.image.url(:detail),
			image: exchange.image.url(:detail),
			name: exchange.name,
			slug: exchange.slug,
			excerpt: exchange_excerpt(exchange, browser.device.mobile? ? 9 : 20),
			blurb: exchange_excerpt(exchange, 10),
			imFollowing: user_signed_in? ? exchange.is_followed_by(current_user) : false,
			followedDate: subscription.created_at < 1.day.ago ? subscription.created_at.strftime("%e %b") : happened_at(subscription.created_at),
			sentence: sentence,
			user: {
			  path: profile_path(slug: user.slug),
			  id: user.id,
				isMuted: user_signed_in? ? current_user.has_muted(user) : false,
				isBlocked: user_signed_in? ? current_user.has_blocked(user) : false,
			  displayName: user.display_name,
			  username: user.username,
			  image: user.profile_photo.url(:square),
				imFollowing: user_signed_in? ? user.is_followed_by(current_user) : false,
				isFollowingMe: user_signed_in? ? current_user.is_followed_by(user) : false
			}
		}
	end
end
