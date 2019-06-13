class ExchangesController < ApplicationController
	def index
		@trending_exchanges = Exchange.trending_list.all.to_a.shuffle
		@exchanges = Exchange.listings.order(:name).all.to_a
		@exchanges.unshift(Exchange.editor_item)
	end

	def show
		if @exchange = Exchange.find_by(slug: params[:slug])
			# @articles_for_carousel = @exchange.articles_for_carousel
			@contributors_for_spotlight = Author.fetch_for_exchange(@exchange).to_a
			got = @contributors_for_spotlight.length
			if got < 6
				fillers = Author.contributors_for_spotlight(6 - got, @contributors_for_spotlight.map(&:id))
				@contributors_for_spotlight = (@contributors_for_spotlight + fillers.to_a) if fillers.any?
			end
			@recent_articles = Article.recent
		else
			render_404
		end
	end
end
