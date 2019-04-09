items = []
@feeds.each do |user_feed_item|
	if user_feed_item.feeds.any?
		if user_feed_item.action_type == 'opinion'
			if item = group_user_opinion_feed_item(user_feed_item)
				item[:feedStamp] = user_feed_item.created_at.to_i
				item[:feedDate] = user_feed_item.created_at < 1.day.ago ? user_feed_item.created_at.strftime("%e %b") : happened_at(user_feed_item.created_at)
				item[:isVisible] = true
				items << item
			else
				(@total_feeds -= 1) if @total_feeds
			end
		elsif user_feed_item.action_type == 'comment'
			if item = group_user_comment_feed_item(user_feed_item)
				item[:feedStamp] = user_feed_item.updated_at.to_i
				item[:feedDate] = user_feed_item.updated_at < 1.day.ago ? user_feed_item.updated_at.strftime("%e %b") : happened_at(user_feed_item.updated_at)
				item[:isVisible] = true
				items << item
			else
				(@total_feeds -= 1) if @total_feeds
			end
		elsif user_feed_item.action_type == 'share'
			share = Share.find(user_feed_item.source_id)
			item = share_as_json_data(share.user, share)
			item[:feedStamp] = user_feed_item.created_at.to_i
			item[:feedDate] = user_feed_item.created_at < 1.day.ago ? user_feed_item.created_at.strftime("%e %b") : happened_at(user_feed_item.created_at)
			item[:isVisible] = true
			items << item
		elsif user_feed_item.action_type == 'categorisation'
			article = Article.find(user_feed_item.source_id)
			exchanges = []
			user_feed_item.feeds.each do |feed|
				if categorisation = Categorisation.find_by(id: feed.actionable_id)
					exchanges << categorisation.exchange
				end
			end
			item = categorisation_as_json_data(user_feed_item.user, article, exchanges)
			item[:feedStamp] = article.published_at.to_i
			item[:feedDate] = article.published_at < 1.day.ago ? article.published_at.strftime("%e %b") : happened_at(article.published_at)
			item[:isVisible] = true
			items << item
		elsif (user_feed_item.action_type == 'follow')
			if item = group_user_follow_feed_item(user_feed_item, current_user)
				item[:feedStamp] = user_feed_item.updated_at.to_i
				item[:feedDate] = user_feed_item.updated_at < 1.day.ago ? user_feed_item.updated_at.strftime("%e %b") : happened_at(user_feed_item.updated_at)
			else
				(@total_feeds -= 1) if @total_feeds
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
			else
				(@total_feeds -= 1) if @total_feeds
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

if items.any?
	items = items.sort! { |a, b| b[:feedStamp] <=> a[:feedStamp] }
	json.feedItems items
	json.countItems items.size
end
json.total @total_feeds if @total_feeds