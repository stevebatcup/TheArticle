json.total @total_notifications if @total_notifications
json.set! :notificationItems do
	json.array! @notifications do |notification|
		json.id notification.id
		json.itemId notification.eventable_id
		json.shareId notification.share_id
		json.stamp notification.updated_at.to_i
		json.happenedAt notification.eventable_type.downcase == 'categorisation' ? happened_at(notification.eventable.article.published_at) : happened_at(notification.updated_at)
		json.date event_date_formatted(notification.updated_at)
		json.body feed_sentencise_with_user(notification.body)
		json.type notification.eventable_type.downcase
		json.specificType notification.specific_type
		json.isSeen notification.is_seen
		if notification.eventable_type.downcase == 'categorisation'
			unless notification.eventable.nil?
				exchange = notification.eventable.exchange
				json.set! :exchange do
					json.image exchange.image.url(:detail)
					json.name exchange.name
					json.path exchange_path(slug: exchange.slug)
				end
				json.set! :article do
					json.path article_path(notification.eventable.article)
				end
			end
		elsif ['mentioner', 'commentmentioner'].include?(notification.eventable_type.downcase)
			share = Share.find(notification.share_id)
			json.mentioner do
				mentioner = User.find(notification.eventable_id)
				json.id mentioner.id
				json.username mentioner.username
				json.displayName mentioner.display_name
				json.shareId share.id
			end
		end
	end
end