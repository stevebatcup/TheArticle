class ArticlesController < ApplicationController
	def index
		params[:page] ||= 1
		params[:per_page] ||= articles_per_page
		if params[:tagged]
			if params[:tagged] == 'editors-picks'
				@articles = Article.editors_picks.page(params[:page]).per(params[:per_page].to_i)
				if params[:page].to_i == 1
					@total = Article.editors_picks.size
					leading_article = Article.leading_editor_article
					if leading_article.present?
						@articles = @articles.all.to_a.unshift(leading_article)
						@articles.delete_at(params[:per_page].to_i - 1)
					end
				end
			end
		elsif params[:exchange]
			exchange = Exchange.find_by(slug: params[:exchange])
			@articles = exchange.articles.not_sponsored
													.includes(:author).references(:author)
													.includes(:exchanges).references(:exchanges)
													.page(params[:page]).per(params[:per_page].to_i)
			if params[:page].to_i == 1
				@total = exchange.articles.not_sponsored.size
			end
		elsif params[:author]
			@contributor = Author.find_by(id: params[:author])
			@articles = @contributor.articles.includes(:exchanges).references(:exchanges).page(params[:page]).per(params[:per_page].to_i)
			if params[:page].to_i == 1
				@total = @contributor.articles.size
			end
		elsif params[:sponsored_picks]
			@articles = Author.get_sponsors_single_posts('sponsored-pick', params[:per_page].to_i)
		end
	end

	def show
		@ad_page_type = 'article'
		if @article = Article.not_remote.where(slug: params[:slug])
													.includes(:author).references(:author)
													.includes(:exchanges).references(:exchanges)
													.first
			@sponsored_picks = Author.get_sponsors_single_posts(nil, 3)
			@trending_exchanges = Exchange.trending_list.all.to_a.shuffle
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
			@articles_in_same_exchange = []
			if @exchange_for_more = @article.exchanges.order(Arel.sql('RAND()')).first
				@articles_in_same_exchange = @exchange_for_more.articles
																											.includes(:exchanges).references(:exchanges)
																											.includes(:author).references(:author)
																											.where.not(id: @article.id)
																											.limit(6)
			end
		end
		@article_share = {
			'comments' => '',
			'rating_well_written' => nil,
			'rating_valid_points' => nil,
			'rating_agree' => nil
		}
		@article_share = current_user.existing_article_rating(@article).as_json if user_signed_in? && current_user.existing_article_rating(@article)
	end
end
