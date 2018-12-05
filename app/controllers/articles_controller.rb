class ArticlesController < ApplicationController
	def index
		@query = params[:query]
		@articles = Article.search(params[:query], match_mode: :boolean)
		@contributors_for_spotlight = Author.contributors_for_spotlight
		@recent_articles = Article.recent
	end

	def show
		@ad_page_type = 'article'
		if @article = Article.where(slug: params[:slug])
													.includes(:author).references(:author)
													.includes(:exchanges).references(:exchanges)
													.first
			@sponsored_picks = Author.get_sponsors_single_posts(nil, 3)
			@trending_exchanges = Exchange.trending_list
			if rand(1..2) == 1
				@firstSideAdType = 'sidecolumn'
				@firstSideAdSlot = 1
				@secondSideAdType = 'bottomsidecolumn'
				@secondSideAdSlot = 0
			else
				@firstSideAdType = 'bottomsidecolumn'
				@firstSideAdSlot = 0
				@secondSideAdType = 'sidecolumn'
				@secondSideAdSlot = 1
			end
			@trending_articles = Article.trending.limit(Author.sponsors.any? ? 4 : 5).all.to_a
			@trending_articles.insert(2, @sponsored_picks.first) if Author.sponsors.any?
			@exchange_for_more = @article.exchanges.order(Arel.sql('RAND()')).first
			@articles_in_same_exchange = @exchange_for_more.articles
																										.includes(:exchanges).references(:exchanges)
																										.includes(:author).references(:author)
																										.where.not(id: @article.id)
																										.limit(6)
		end
	end
end
