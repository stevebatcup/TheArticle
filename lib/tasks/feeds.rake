namespace :feeds do
	task :fix_cat_dates => :environment do
		page = (ENV['page'] || 1).to_i - 1
		feed_limit = ((ENV['limit'] || 2).to_i)
		# puts ".limit(#{feed_limit}).offset(#{page*feed_limit})"
		FeedUser.where(action_type: 'categorisation').order(id: :desc).limit(feed_limit).offset(page*feed_limit).each do |feed|
			if article = Article.find(feed.source_id)
				puts "fixing for article #{article.id}"
				feed.update_attribute(:updated_at, article.published_at)
			end
		end
	end

	task :convert_categorisations => :environment do
		page = (ENV['page'] || 1).to_i - 1
		feed_limit = ((ENV['limit'] || 2).to_i)
		Feed.where(actionable_type: 'Categorisation').limit(feed_limit).offset(page*feed_limit).each do |feed|
			# puts feed.id
			if categorisation = Categorisation.find_by(id: feed.actionable_id)
				unless user_feed_item = FeedUser.find_by(action_type: 'categorisation', source_id: categorisation.article_id, user_id: feed.user_id)
					user_feed_item = FeedUser.new({
						user_id: feed.user_id,
						action_type: 'categorisation',
						source_id: categorisation.article_id,
						created_at: feed.created_at,
						updated_at: feed.created_at
					})
				end
				user_feed_item.feeds << feed unless user_feed_item.feeds.include?(feed)
				user_feed_item.save
			end
		end
	end

end
