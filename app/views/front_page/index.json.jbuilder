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
		items << comment_as_json_data(feed_item.user, feed_item.actionable)
	when 'Opinion'
		items << opinion_as_json_data(feed_item.user, feed_item.actionable)
	when 'Follow'
		items << follow_as_json_data(feed_item.user, feed_item.actionable)
	when 'Categorisation'
		items << categorisation_as_json_data(feed_item.user, feed_item.actionable)
	end
end
json.feedItems items



# SUGGESTIONS
json.set! :suggestions do
	json.array! @suggestions do |suggestion|
		user = suggestion.suggested
		json.id user.id
		json.displayName user.display_name
		json.username user.username
		json.reason suggestion.reason
		json.bio bio_excerpt(user, browser.device.mobile? ? 18 : 28)
		json.profilePhoto user.profile_photo.url(:square)
		json.coverPhoto user.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
		json.imFollowing user.is_followed_by(current_user)
		json.isFollowingMe current_user.is_followed_by(user)
	end
end