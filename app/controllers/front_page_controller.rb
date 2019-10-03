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
				@most_rated_articles = Article.most_rated(10)
			end
			format.json do
				@page = (params[:page] || 1).to_i
				@per_page = (params[:per_page] || 10).to_i
				@section = params[:section]
				if (@page == 1) && (@section == 'articles')
					@latest_articles = Article.latest.limit(20)
					@sponsored_picks = Article.sponsored
																		.includes(:exchanges)
																		.references(:exchanges)
																		.includes(:keyword_tags)
																		.references(:keyword_tags)
																		.where("keyword_tags.slug = ?", 'sponsored-pick')
																		.order(Arel.sql('RAND()'))
																		.limit(20)
																		.to_a
					@trending_exchanges = Exchange.trending_list.all.to_a.shuffle
				end
				@feeds = Feed.fetch_user_feeds(current_user, false, @page, @per_page, @section)
				@total_feeds = Feed.fetch_user_feeds(current_user, true, @page, @per_page, @section).length if @page == 1
			end
		end
	end
end
