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
			puts "deleting subscription feeds #{subscription.id}...."
			subscription.delete_retrospective_feeds
			puts ""
		end

		subs.each do |subscription|
			puts "building subscription feeds #{subscription.id}...."
			subscription.build_retrospective_feeds
			puts ""
		end
	end

	task :clean => :environment do
		cutoff_weeks = 10
		item_limit = 40000
		puts "Running feeds:clean...."

		master_notifications = Notification.where("created_at < DATE_SUB(NOW(), INTERVAL #{cutoff_weeks} week)").order(created_at: :desc, id: :desc).limit(1)
		if master_notifications.any?
			master_notification = master_notifications.first
			puts "Master Notification ID: #{master_notification.id}"

			# remove notifications and feeds_notifications
			FeedNotification.where("notification_id <= #{master_notification.id}")
												.order(notification_id: :desc)
												.limit(item_limit)
												.delete_all
			sleep(1)
			Notification.where("id <= #{master_notification.id}")
												.order(id: :desc)
												.limit(item_limit)
												.delete_all
			sleep(5)
		else
			puts "No notifications found before #{cutoff_weeks} weeks ago"
		end

		master_feeds = Feed.where("created_at < DATE_SUB(NOW(), INTERVAL #{cutoff_weeks} week)").order(created_at: :desc, id: :desc).limit(1)
		if master_feeds.any?
			master_feed = master_feeds.first
			puts "Master Feed ID: #{master_feed.id}"

			# remove notifications for feeds
			FeedNotification.where("feed_id <= #{master_feed.id}")
												.order(feed_id: :desc)
												.limit(item_limit)
												.delete_all
			sleep(1)

			# remove feeds, feed_users and join tables
			Feed.where("id <= #{master_feed.id}")
											.order(id: :desc)
											.limit(item_limit)
											.destroy_all

		else
			puts "No feeds found before #{cutoff_weeks} weeks ago"
		end

		puts "Done!\n"
	end
end