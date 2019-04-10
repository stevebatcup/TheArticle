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
end
