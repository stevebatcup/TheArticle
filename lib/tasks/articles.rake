namespace :articles do
	task :fetch_scheduled_posts => :environment do
		future_articles = FutureArticle.where("publish_date < DATE_SUB(CURTIME(), INTERVAL 1 MINUTE)")
		puts "Running scheduled article check"
		if future_articles.any?
			puts "#{future_articles.length} scheduled articles found"
			future_articles.each do |fa|
				unless Article.find_by(wp_id: fa.wp_id)
					Article.schedule_create_or_update(fa.wp_id, fa.publish_date)
					puts "Scheduling article #{fa.wp_id}"
				else
					puts "Article #{fa.wp_id} already exists"
				end
				fa.destroy
			end
		end
	end
end
