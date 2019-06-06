class ArticlesController < ApplicationController
	def index
		respond_to do |format|
			format.html do
				render_404
			end
			format.rss do
				@articles = Article.latest.limit(100)
				render :layout => false
			end
			format.json do
				params[:page] ||= 1
				params[:per_page] ||= articles_per_page
				if params[:tagged]
					if params[:tagged] == 'editors-picks'
						@articles = Article.editors_picks(params[:page].to_i, params[:per_page].to_i)
						if params[:page].to_i == 1
							@total = Article.editors_picks(0).size
							leading_article = Article.leading_editor_article
							if leading_article.present?
								@articles = @articles.all.to_a.unshift(leading_article)
								# @articles.delete_at(params[:per_page].to_i - 1)
							end
						end
					end
				elsif params[:exchange]
					per_page = params[:per_page].to_i
					if params[:include_sponsored]
						sponsored_frequency = 5
						set = (params[:page].to_i % per_page)
						set_offset = 3
						sponsored_begin_offset = set + set_offset
						sponsored_begin_offset = sponsored_begin_offset - per_page if sponsored_begin_offset > per_page
						# sponsored_limit = (sponsored_begin_offset == sponsored_frequency) ? sponsored_frequency - 1 : sponsored_frequency
						sponsored_limit = sponsored_frequency
						sponsored_articles = Article.sponsored
																			.includes(:author).references(:author)
																			.includes(:exchanges).references(:exchanges)
																			.order(created_at: :desc)
																			.limit(sponsored_limit)
						items_to_get = per_page - (sponsored_articles.length)
					end

					if params[:exchange] == 'latest-articles'
						@articles = Article.latest.page(params[:page]).per(items_to_get)
						@total = Article.not_sponsored.not_remote.size if params[:page].to_i == 1
					elsif exchange = Exchange.find_by(slug: params[:exchange])
						@articles = exchange.articles.not_sponsored
																.includes(:author).references(:author)
																.includes(:exchanges).references(:exchanges)
																.order("published_at DESC")
																.page(params[:page]).per(items_to_get)
						if params[:exclude_id]
							@articles = @articles.where.not("articles.id = ?", params[:exclude_id])
						end
						if params[:page].to_i == 1
							if params[:exclude_id]
								@total = exchange.articles.where.not("articles.id = ?", params[:exclude_id]).not_sponsored.not_remote.size
							else
								@total = exchange.articles.not_sponsored.not_remote.size
							end
						end
					else
						@articles = []
						@total = 0
					end

					if params[:include_sponsored]
						@articles = @articles.to_a
						sponsored_articles.each_with_index do |sa, i|
							key = (sponsored_begin_offset + (i * sponsored_frequency)) - 1
							if @articles[key]
								@articles.insert(key, sa)
							else
								@articles.push(sa) if @articles.length > 3
								break
							end
						end
					end

				elsif params[:author]
					@contributor = Author.find_by(id: params[:author])
					@articles = @contributor.articles
																	.includes(:exchanges)
																	.references(:exchanges)
																	.order("published_at DESC")
																	.page(params[:page])
																	.per(params[:per_page].to_i)
					if params[:page].to_i == 1
						@total = @contributor.articles.size
					end
				elsif params[:sponsored_picks]
					@articles = Author.get_sponsors_single_posts('sponsored-pick', 6)
					ordered = @articles.map(&:published_at)
				end
			end
		end
	end

	def show
		@ad_page_type = 'article'
		if @article = Article.not_remote.where(slug: params[:slug])
													.includes(:author).references(:author)
													.includes(:exchanges).references(:exchanges)
													.first
			@sponsored_picks = []
			unless @article.is_sponsored?
				@sponsored_picks = Author.get_sponsors_single_posts('sponsored-pick', 3)
			end
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
			@trending_articles = Article.latest.limit(Author.sponsors.any? ? 4 : 5).all.to_a
			if @sponsored_picks.any? && Author.sponsors.any?
				@trending_articles.insert(2, @sponsored_picks.first)
			end
			@exchange_for_more = @article.exchanges.order(Arel.sql('RAND()')).first
			@article_share = {
				'comments' => '',
				'rating_well_written' => nil,
				'rating_valid_points' => nil,
				'rating_agree' => nil
			}
			@article_share = current_user.existing_article_rating(@article).as_json if user_signed_in? && current_user.existing_article_rating(@article)
		else
			render_404
		end
	end
end
