class ExchangesController < ApplicationController
	def index
		respond_to do |format|
			format.html do
				@trending_exchanges = Exchange.trending_list.all.to_a.shuffle
				@exchanges = Exchange.listings.order(:name).all.to_a
				@exchanges.unshift(Exchange.editor_item)
			end

			format.json do
				@mode = (params[:mode] || :all).to_sym
				if @mode == :homepage
					@exchanges = Exchange.most_recent_articles(['editor-at-the-article', 'sponsored'])
					@exchanges.unshift(Exchange.new({name: 'Latest Articles', slug: 'latest-articles', description: '', image: ''}))
				elsif @mode == :wizard
					trending_exchanges = Exchange.trending_list
					other_exchanges = Exchange.non_trending.where("slug != 'editor-at-the-article'").order(article_count: :desc)
					@exchanges = trending_exchanges.to_a.concat(other_exchanges)
				else
					@exchanges = Exchange.all_complete.order(:name).all.to_a
				end
			end
		end
	end

	def show
		@exchange = Exchange.find_by(slug: params[:slug])
		respond_to do |format|
			format.html do
				if @exchange
					# @articles_for_carousel = @exchange.articles_for_carousel
					@contributors_for_spotlight = Author.fetch_for_exchange(@exchange).to_a
					got = @contributors_for_spotlight.length
					if got < 6
						fillers = Author.contributors_for_spotlight(6 - got, @contributors_for_spotlight.map(&:id))
						@contributors_for_spotlight = (@contributors_for_spotlight + fillers.to_a) if fillers.any?
					end
					sponsored_picks = Author.get_sponsors_single_posts('sponsored-pick', 1, :random)
					@recent_articles = Article.latest.limit(Author.sponsors.any? ? 4 : 5).all.to_a
					@recent_articles.insert(2, sponsored_picks.first) if Author.sponsors.any?
				else
					render_404
				end
			end
			format.json do
			end
		end
	end
end
