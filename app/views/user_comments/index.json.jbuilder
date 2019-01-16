json.total @total if @total
items = []
@comments.each do |feed_item|
	items << comment_as_json_data(feed_item.actionable)
end
json.comments items