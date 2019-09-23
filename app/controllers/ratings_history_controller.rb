class RatingsHistoryController < ApplicationController
	before_action :authenticate_basic_user

	def index
		respond_to do |format|
			@article = Article.find(params[:article_id])
			format.json do
				@page = (params[:page] || 1).to_i
				if @page == 1
					@total = @article.shares.where(share_type: 'rating').length
				end
				@ratings = @article.shares.where(share_type: 'rating')
																		.order(created_at: :desc)
																		.page(@page)
																		.per(params[:per_page])
			end
		end
	end

	def show
		respond_to do |format|
			@article = Article.find(params[:id])
			format.html do
				unless browser.device.mobile?
					@sponsored_picks = Author.get_sponsors_single_posts('sponsored-pick', 3)
					@trending_articles = Article.latest.limit(Author.sponsors.any? ? 4 : 5).all.to_a
					@trending_articles.insert(2, @sponsored_picks.first) if Author.sponsors.any?
					@contributors_for_spotlight = Author.contributors_for_spotlight(3)
					@recent_articles = Article.recent
					@trending_exchanges = Exchange.trending_list.all.to_a.shuffle
				end
			end
		end
	end
end
