items = []

# USER FEEDS
@user_feeds.each do |user_feed_item|
	if user_feed_item.feeds.any?
		if user_feed_item.action_type == 'opinion'
			if item = group_user_opinion_feed_item(user_feed_item)
				item[:feedStamp] = user_feed_item.created_at.to_i
				item[:isVisible] = true
				items << item
			end
		elsif user_feed_item.action_type == 'comment'
			if item = group_user_comment_feed_item(user_feed_item)
				item[:feedStamp] = user_feed_item.updated_at.to_i
				item[:isVisible] = true
				items << item
			end
		elsif (user_feed_item.action_type == 'follow')
			if item = group_user_follow_feed_item(user_feed_item, current_user)
				item[:feedStamp] = user_feed_item.updated_at.to_i
			end
			unless @my_followings_ids.include?(user_feed_item.source_id) || @my_muted_follow_ids.include?(user_feed_item.source_id)
				item[:isVisible] = false
			else
				item[:isVisible] = true
			end
			items << item
		elsif user_feed_item.action_type == 'subscription'
			if item = group_user_subscription_feed_item(user_feed_item)
				item[:feedStamp] = user_feed_item.created_at.to_i
			end
			if @my_exchange_ids.include?(user_feed_item.source_id) || @my_muted_exchange_ids.include?(user_feed_item.source_id)
				item[:isVisible] = false
			else
				item[:isVisible] = true
			end
			items << item
		end
	end
end

# FEEDS
categorisation_feed_items = []
json.total @total_feeds if @total_feeds
@feeds.each do |feed_item|
	unless feed_item.actionable.nil?
		case feed_item.actionable_type
		when 'Share'
			item = share_as_json_data(feed_item.user, feed_item.actionable)
			item[:feedStamp] = feed_item.created_at.to_i
			item[:isVisible] = true
			items << item
		when 'Categorisation'
			categorisation_feed_items << feed_item
		end
	end
end

# Grouping the categorisations by article
if categorisation_feed_items.any?
	categorisation_articles = {}
	categorisation_feed_items.each do |cfi|
		article_id = cfi.actionable.article.id
		categorisation_articles[article_id] ||= []
		categorisation_articles[article_id] << cfi
	end

	categorisation_articles.values.each do |categorisation_article|
		exchanges = []
		categorisation_article.each do |ca|
			exchanges << ca.actionable.exchange
		end
		item = categorisation_as_json_data(categorisation_article.first.user, categorisation_article.first.actionable, exchanges)
		item[:feedStamp] = categorisation_article.first.actionable.article.published_at.to_i
		item[:isVisible] = true
		items << item
	end
end

if items.any?
	items = items.sort! { |a, b| b[:feedStamp] <=> a[:feedStamp] }
	lastActivityOffset = 1

	# add in the suggestions
	if @page == 1
		insertIndex = 10
		lastActivityOffset = 2
		if items.size > insertIndex
			suggestionItem = {
				type: 'suggestion',
				stamp: items[insertIndex][:stamp]+1,
				feedStamp: items[insertIndex][:stamp]+1,
				isVisible: true
			}
			items.insert(insertIndex, suggestionItem)
		else
			suggestionItem = {
				type: 'suggestion',
				stamp: items.last[:stamp]+1,
				feedStamp: items.last[:stamp]+1,
				isVisible: true
			}
			items.push suggestionItem
		end
	end
	json.feedItems items
	json.countItems items.size
	json.nextActivityTime Feed.latest_activity_time_for_user(current_user, items.last[:feedStamp] - lastActivityOffset).to_i
end