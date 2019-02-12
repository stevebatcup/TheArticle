json.total @total if @total
items = []
@comments.each do |feed_item|
	unless feed_item.actionable.nil?
		items << comment_as_json_data(feed_item.actionable)
	end
end
json.comments items