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

	task :regenerate_subscription_feeds => :environment do
		page = (ENV['page'] || 1).to_i - 1
		sub_limit = ((ENV['limit'] || 100).to_i)
		if ENV['user_id'].present?
			puts "run by user_id #{ENV['user_id']}"
			subs = Subscription.order(id: :asc).where(user_id: ENV['user_id'])
		else
			puts "run by limits"
			subs = Subscription.order(id: :asc).limit(sub_limit).offset(page*sub_limit)
		end
		subs.each do |subscription|
			puts "handling subscription #{subscription.id}...."
			subscription.delete_retrospective_feeds
			subscription.build_retrospective_feeds
			puts ""
		end
	end

end