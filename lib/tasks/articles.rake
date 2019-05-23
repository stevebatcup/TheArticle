require 'uri'
namespace :articles do
	task :fetch_scheduled_posts => :environment do
		wp_url = Rails.application.credentials.wordpress_url[Rails.env.to_sym]
		puts "Running scheduled article check..."
		open(wp_url) do
			puts "...#{wp_url} has been hit"
			future_articles = FutureArticle.where("publish_date < DATE_SUB(CURTIME(), INTERVAL 2 MINUTE)").order(id: :asc)
			if future_articles.any?
				puts "...#{future_articles.length} scheduled articles found"
				fa = future_articles.first
				unless Article.find_by(wp_id: fa.wp_id)
					Article.schedule_create_or_update(fa.wp_id, fa.publish_date)
					puts "...scheduling article #{fa.wp_id}..."
				else
					puts "...article #{fa.wp_id} already exists"
				end
				fa.destroy
			end
		end
		puts "...done!"
	end
end
