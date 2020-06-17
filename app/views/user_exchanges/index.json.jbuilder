json.total @total if @total
if params[:basic].present?
	json.set! :exchanges do
		json.array! @subscriptions do |subscription|
			exchange = subscription.exchange
			json.id exchange.id
			json.slug exchange.slug
			json.name exchange.name
		end
	end
else
	json.exchanges subscription_list_as_json_data(@user, @subscriptions)
end