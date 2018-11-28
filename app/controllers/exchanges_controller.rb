class ExchangesController < ApplicationController
	def index
		@trending_exchanges = Exchange.trending_list
		@exchanges = Exchange.listings.all.to_a
		@exchanges.unshift(Exchange.editor_item)
	end

	def show
		@exchange = Exchange.find_by(slug: params[:slug])
		@articles_for_carousel = []
		@articles_for_carousel = @exchange.articles.unscoped.not_sponsored.order("RAND()").limit(12)
		@articles_for_listings = @exchange.articles.not_sponsored
		@contributors_for_spotlight = Author.contributors_for_spotlight
		@recent_articles = Article.recent
	end
end
