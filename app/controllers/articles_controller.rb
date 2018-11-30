class ArticlesController < ApplicationController
	def index
		@query = params[:query]
		@search = Article.search do
			fulltext params[:query]
		end
		@articles = @search.results
		@contributors_for_spotlight = Author.contributors_for_spotlight
		@recent_articles = Article.recent
	end

	def show
		@ad_page_type = 'article'
		if @article = Article.find_by(slug: params[:slug])
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
			if Author.sponsors.any?
				sponsored_post =
				@trending_articles.insert 2, Author.get_sponsors_single_posts(nil, 1).first
			end
			@exchange_for_more = @article.exchanges.order("RAND()").first
			@articles_in_same_exchange = @exchange_for_more.articles.where.not(id: @article.id).limit 6
		end
	end
end
