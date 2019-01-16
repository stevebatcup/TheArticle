json.total @total if @total
items = []
@opinions.each do |feed_item|
	items << opinion_as_json_data(feed_item.actionable)
end
json.opinions items