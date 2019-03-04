class ExchangesController < ApplicationController
	def index
		@trending_exchanges = Exchange.trending_list.all.to_a.shuffle
		@exchanges = Exchange.listings.order(:name).all.to_a
		@exchanges.unshift(Exchange.editor_item)
	end

	def show
		@exchange = Exchange.find_by(slug: params[:slug])
		@articles_for_carousel = @exchange.articles_for_carousel
		@contributors_for_spotlight = Author.contributors_for_spotlight
		@recent_articles = Article.recent
	end
end
