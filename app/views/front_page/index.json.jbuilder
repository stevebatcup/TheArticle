items = []

# USER FEEDS
@user_feeds.each do |user_feed_item|
	if user_feed_item.feeds.any?
		if user_feed_item.action_type == 'opinion'
			if item = group_user_opinion_feed_item(user_feed_item)
				item[:feedStamp] = user_feed_item.created_at.to_i
				item[:feedDate] = user_feed_item.created_at < 1.day.ago ? user_feed_item.created_at.strftime("%e %b") : happened_at(user_feed_item.created_at)
				item[:isVisible] = true
				items << item
			end
		elsif user_feed_item.action_type == 'comment'
			if item = group_user_comment_feed_item(user_feed_item)
				item[:feedStamp] = user_feed_item.updated_at.to_i
				item[:feedDate] = user_feed_item.updated_at < 1.day.ago ? user_feed_item.updated_at.strftime("%e %b") : happened_at(user_feed_item.updated_at)
				item[:isVisible] = true
				items << item
			end
		elsif (user_feed_item.action_type == 'follow')
			if item = group_user_follow_feed_item(user_feed_item, current_user)
				item[:feedStamp] = user_feed_item.updated_at.to_i
				item[:feedDate] = user_feed_item.updated_at < 1.day.ago ? user_feed_item.updated_at.strftime("%e %b") : happened_at(user_feed_item.updated_at)
			end
			if @my_followings_ids.include?(user_feed_item.source_id) || @my_muted_follow_ids.include?(user_feed_item.source_id)
				item[:isVisible] = false
			else
				item[:isVisible] = true
			end
			items << item
		elsif user_feed_item.action_type == 'subscription'
			if item = group_user_subscription_feed_item(user_feed_item)
				item[:feedStamp] = user_feed_item.updated_at.to_i
				item[:feedDate] = user_feed_item.updated_at < 1.day.ago ? user_feed_item.updated_at.strftime("%e %b") : happened_at(user_feed_item.updated_at)
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
			item[:feedDate] = feed_item.created_at < 1.day.ago ? feed_item.created_at.strftime("%e %b") : happened_at(feed_item.created_at)
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
		ca_feed = categorisation_article.first
		item = categorisation_as_json_data(ca_feed.user, ca_feed.actionable, exchanges)
		item[:feedStamp] = ca_feed.actionable.article.published_at.to_i
		item[:feedDate] = ca_feed.actionable.article.published_at < 1.day.ago ? ca_feed.actionable.article.published_at.strftime("%e %b") : happened_at(ca_feed.actionable.article.published_at)
		item[:isVisible] = true
		items << item
	end
end

if items.any?
	items = items.sort! { |a, b| b[:feedStamp] <=> a[:feedStamp] }
	json.feedItems items
	json.countItems items.size
	json.nextActivityTime Feed.latest_activity_time_for_user(current_user, items.last[:feedStamp] - 1).to_i
end