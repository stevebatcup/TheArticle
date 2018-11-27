class ExchangesController < ApplicationController
	def index
		@trending_exchanges = Exchange.trending_list
		@exchanges = Exchange.listings.all.to_a
		@exchanges.unshift(Exchange.editor_item)
	end

	def show
		@exchange = Exchange.find_by(slug: params[:slug])
		@contributors_for_spotlight = Author.contributors_for_spotlight
		@recent_articles = Article.recent
	end
end
