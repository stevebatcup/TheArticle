class ContributorRatingsController < ApplicationController
	def index
		@order_by = (params[:order_by] || :comments).to_sym
		respond_to do |format|
			format.json do
				@page = (params[:page] || 1).to_i
				@total = current_user.shares.ratings.includes(:article).references(:article)
											.where("articles.author_id = ?", params[:contributor_id]).length if @page == 1
				@ratings = current_user.shares.ratings.includes(:article).references(:article)
											.where("articles.author_id = ?", params[:contributor_id])
											.page(@page)
											.per(params[:per_page])
				case @order_by
				when :comments
					@ratings  = @ratings.order("(post > '') DESC").order(created_at: :desc)
				when :oldest
					@ratings  = @ratings.order(created_at: :asc)
				when :newest
					@ratings  = @ratings.order(created_at: :desc)
				end
			end
		end
	end

	def show
		respond_to do |format|
			@contributor = Author.find(params[:id])
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
