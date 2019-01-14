# FEEDS
json.total @total_feeds if @total_feeds
items = []
@feeds.each do |feed_item|
	case feed_item.actionable_type
	when 'Subscription'
		items << subscription_item_as_json_data(feed_item.user, feed_item.actionable)
	when 'Share'
		items << share_as_json_data(feed_item.user, feed_item.actionable)
	when 'Comment'
		items << comment_as_json_data(feed_item.actionable)
	when 'Opinion'
		items << opinion_as_json_data(feed_item.actionable)
	when 'Follow'
		items << follow_as_json_data(feed_item.actionable, current_user)
	when 'Categorisation'
		items << categorisation_as_json_data(feed_item.user, feed_item.actionable)
	end
end
json.feedItems items


# SUGGESTIONS
json.suggestions suggestions_as_json_data(current_user, @suggestions) if @suggestions