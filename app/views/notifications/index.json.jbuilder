json.total @total_notifications if @total_notifications
json.set! :notificationItems do
	json.array! @notifications do |notification|
		json.id notification.id
		json.itemId notification.eventable_id
		json.stamp notification.updated_at.to_i
		json.happenedAt happened_at(notification.updated_at)
		json.date notification.updated_at.strftime("%e %b")
		json.body notification.body
		json.type notification.eventable_type.downcase
		json.specificType notification.specific_type
		json.isSeen notification.is_seen
		if notification.eventable_type.downcase == 'opiniongroup'
			json.shareId notification.eventable.share.id
		elsif notification.eventable_type.downcase == 'categorisation'
			exchange = notification.eventable.exchange
			json.set! :exchange do
				json.image exchange.image.url(:detail)
				json.name exchange.name
				json.path exchange_path(slug: exchange.slug)
			end
		end
	end
end