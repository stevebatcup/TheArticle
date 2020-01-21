class FrontPageController < ApplicationController
	before_action :authenticate_user!
	layout	:set_layout

	def index
		respond_to	do |format|
			format.html do
				@sponsored_picks = Author.get_sponsors_single_posts('sponsored-pick', 1, :random)
				@trending_articles = Article.latest.limit(Author.sponsors.any? ? 4 : 5).all.to_a
				@trending_articles.insert(2, @sponsored_picks.first) if Author.sponsors.any?
				@contributors_for_spotlight = Author.contributors_for_spotlight(3)
				@recent_articles = Article.recent
				@trending_exchanges = Exchange.trending_list.all.to_a.shuffle
				ProfileSuggestionsGeneratorJob.perform_later(current_user, false, 15)
				@most_rated_articles = Article.most_rated(10, 14)
			end

			format.json do
				@page = (params[:page] || 1).to_i
				@per_page = (params[:per_page] || 10).to_i
				@section = params[:section]
				@bypass_article_feeds = (@section == 'articles' && params[:bypass_article_feeds].present?)
				@feeds = Feed.fetch_user_feeds(current_user, false, @page, @per_page, @section, @bypass_article_feeds)
				@total_feeds = Feed.fetch_user_feeds(current_user, true, @page, @per_page, @section, @bypass_article_feeds).length if @page == 1
			end
		end
	end
end
