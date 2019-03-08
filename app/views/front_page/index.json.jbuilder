items = []

# USER FEEDS
@user_feeds.each do |user_feed_item|
	if user_feed_item.feeds.any?
		if user_feed_item.action_type == 'opinion'
			if item = group_user_opinion_feed_item(user_feed_item)
				items << item
			end
		elsif user_feed_item.action_type == 'comment'
			if item = group_user_comment_feed_item(user_feed_item)
				items << item
			end
		elsif (user_feed_item.action_type == 'follow') && (user_feed_item.feeds.length > 1)
			unless @my_followings_ids.include?(user_feed_item.source_id) || @my_muted_follow_ids.include?(user_feed_item.source_id)
				if item = group_user_follow_feed_item(user_feed_item, current_user)
					items << item
				end
			end
		elsif user_feed_item.action_type == 'subscription'
			unless @my_exchange_ids.include?(user_feed_item.source_id) || @my_muted_exchange_ids.include?(user_feed_item.source_id)
				if item = group_user_subscription_feed_item(user_feed_item)
					items << item
				end
			end
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
			items << share_as_json_data(feed_item.user, feed_item.actionable)
		when 'Categorisation'
			categorisation_feed_items << feed_item
		end
	end
end

# Grouping the categorisatios by article
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
		# foo
		items << categorisation_as_json_data(categorisation_article.first.user, categorisation_article.first.actionable, exchanges)
	end
end

if (@page == 1) && browser.device.mobile?
	items << {
		type: 'suggestion',
		stamp: items.any? ? items.last[:stamp]+1 : Time.now.to_i
	}
end

if items.any?
	json.feedItems items.sort! { |a, b| b[:stamp] <=> a[:stamp] }
end


# SUGGESTIONS
json.suggestions suggestions_as_json_data(current_user, @suggestions) if @suggestions