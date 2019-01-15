json.total @total_notifications if @total_notifications
json.set! :notificationItems do
	json.array! @notifications do |notification|
		json.itemId notification.eventable_id
		json.stamp notification.created_at.to_i
		json.happenedAt happened_at(notification.created_at)
		json.date notification.created_at.strftime("%e %b")
		json.body notification.body
		json.type notification.eventable_type.downcase
		json.specificType notification.specific_type
		if notification.eventable_type.downcase == 'opinion'
			json.opinionatorName notification.eventable.user.display_name
		elsif notification.eventable_type.downcase == 'follow'
			json.followerName notification.eventable.user.display_name
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