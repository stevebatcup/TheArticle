class NotificationsController < ApplicationController
	before_action :authenticate_user!

	def index
		respond_to do |format|
			format.html do
				@sponsored_picks = Author.get_sponsors_single_posts(nil, 3)
				@trending_articles = Article.trending.limit(Author.sponsors.any? ? 4 : 5).all.to_a
				@trending_articles.insert(2, @sponsored_picks.first) if Author.sponsors.any?
				@contributors_for_spotlight = Author.contributors_for_spotlight(3)
				@recent_articles = Article.recent
				@trending_exchanges = Exchange.trending_list.all.to_a.shuffle
			end
			format.json do
				page = (params[:page] || 1).to_i
				per_page = (params[:per_page] || 20).to_i
				@total_notifications = Notification.last_weeks_for_user(current_user, 4).size if page == 1
				@notifications = Notification.last_weeks_for_user(current_user, 4)
																			.order(created_at: :desc)
																			.page(page)
																			.per(per_page)
			end
		end
	end
end
