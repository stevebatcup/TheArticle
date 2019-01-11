class FrontPageController < ApplicationController
	before_action :authenticate_user!
	layout	:set_layout

	def index
		respond_to	do |format|
			format.html do
				@sponsored_picks = Author.get_sponsors_single_posts(nil, 3)
				@trending_articles = Article.trending.limit(Author.sponsors.any? ? 4 : 5).all.to_a
				@trending_articles.insert(2, @sponsored_picks.first) if Author.sponsors.any?
				@contributors_for_spotlight = Author.contributors_for_spotlight(3)
				@recent_articles = Article.recent
				@trending_exchanges = Exchange.trending_list.all.to_a.shuffle
			end
			format.json do
				page = params[:page].to_i || 1
				per_page = 3
				@total_feeds = Feed.fetch_for_followings_of_user(current_user, 1, 0).size if page == 1
				@feeds = Feed.fetch_for_followings_of_user(current_user, 1, per_page)
				@suggestions = current_user.pending_suggestions
			end
		end
	end
end
