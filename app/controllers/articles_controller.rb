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
				@latest_for_feed = false
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
					elsif params[:tagged].include?(",")
						tags = params[:tagged].split(",")
						@total = Article.includes(:keyword_tags).where(keyword_tags: {slug: tags}).size if params[:page].to_i == 1
						@articles = Article.includes(:keyword_tags)
													.where(keyword_tags: {slug: tags})
													.order(published_at: :desc)
													.page(params[:page])
													.per(params[:per_page].to_i)
					end
				elsif params[:exchange]
					per_page = params[:per_page].to_i
					if params[:include_sponsored]
						sponsored_frequency = 5
						if params[:page].to_i % 4 == 0
							offset = 9
						elsif params[:page].to_i % 3 == 0
							offset = 6
						elsif params[:page].to_i % 2 == 0
							offset = 3
						else
							offset = 0
						end
						sponsored_articles = Article.sponsored.includes(:exchanges)
																				.references(:exchanges)
																				.order(published_at: :desc)
																				.limit(3)
																				.offset(offset)
																				.to_a
						items_to_get = articles_per_page - (sponsored_articles.length)
					else
						items_to_get = per_page
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
						first_key = 3
						sponsored_articles.each_with_index do |sa, i|
							key = (first_key + (i * sponsored_frequency))
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
					@articles = @contributor.all_articles
																	.order("published_at DESC")
																	.page(params[:page])
																	.per(params[:per_page].to_i)
					if params[:page].to_i == 1
						@total = @contributor.articles.size
					end
				elsif params[:sponsored_picks]
					limit = (params[:limit] || 6).to_i
					@articles = Author.get_sponsors_single_posts('sponsored-pick', limit)
					ordered = @articles.map(&:published_at)
				elsif params[:latest_for_feed]
					@latest_for_feed = true
					@articles = Article.latest.limit(params[:per_page])
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
			build_ad_slots
		else
			render_404
		end
	end

	def show_nativo
		@ad_page_type = 'article'
		build_ad_slots
	end

	helper_method	:article_share
	def article_share(article)
		@article_share ||= begin
			if user_signed_in? && current_user.existing_article_rating(article)
				current_user.existing_article_rating(article).as_json
			else
				{
					'comments' => '',
					'rating_well_written' => nil,
					'rating_valid_points' => nil,
					'rating_agree' => nil
				}
			end
		end
	end

	helper_method	:trending_articles
	def trending_articles
		@trending_articles ||= begin
			articles = Article.latest.limit(Author.sponsors.any? ? 4 : 5).all.to_a
			if sponsored_picks.any?
				trending_sponsored_article = Article.sponsored.includes(:exchanges)
																				.references(:exchanges)
																				.includes(:keyword_tags)
																				.references(:keyword_tags)
																				.where("keyword_tags.slug = ?", 'sponsored-pick')
																				.where.not(id: [102])
																				.order(Arel.sql('RAND()'))
																				.limit(1)
																				.first
				articles.insert(2, trending_sponsored_article) unless trending_sponsored_article.nil?
			end
			articles
		end
	end


	helper_method	:sponsored_picks
	def sponsored_picks
		@sponsored_picks ||= Article.sponsored.includes(:exchanges)
			.references(:exchanges)
			.includes(:keyword_tags)
			.references(:keyword_tags)
			.where("keyword_tags.slug = ?", 'sponsored-pick')
			.order(Arel.sql('RAND()'))
			.limit(4)
			.to_a
	end

private

	def build_ad_slots
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
	end
end
