json.total @total if @total
items = []
@opinions.each do |feed_item|
	unless feed_item.actionable.nil? || feed_item.actionable.share.nil?
		items << opinion_as_json_data(feed_item.actionable)
	end
end
json.opinions items