class SearchController < ApplicationController
	include ActionView::Helpers::TextHelper

	def index
		@query = params[:query]
		@query.sub!(%r{^#},"") if @query.include?('#')
		respond_to do |format|
			format.json do
				if params[:mode] == :suggestions
					begin
						if @query.present?
							@recent_searches = @who_to_follow = @trending_articles = @trending_exchanges = []
							@topics = KeywordTag.search(@query, 5)
							@exchanges = Exchange.search(@query, 5)
							@contributors = Author.search(@query, 5)
							@profiles = User.search(@query, 5)
						else
							@topics = @exchanges = @contributors = @profiles = []
							if user_signed_in? && current_user.followings.any?
								@recent_searches = current_user.search_logs.order(created_at: :desc).limit(5).pluck(:term).uniq
								@profile_suggestions_mode = :people_might_know
								@who_to_follow = current_user.pending_suggestions.limit(5).map(&:suggested)
							else
								@recent_searches = []
								@profile_suggestions_mode = :who_to_follow
								@who_to_follow = User.popular_users.limit(5)
							end
							@latest_articles = Article.latest.order(published_at: :desc).limit(5)
							@trending_exchanges = Exchange.trending_list.limit(5).to_a.shuffle
						end
						render :index_suggestions
					rescue Exception => e
						render :index_suggestions
					end
				elsif params[:mode] == :full
					begin
						articles = Article.search(@query).to_a
						contributors = Author.search(@query).to_a
						exchanges = Exchange.search(@query).to_a
						posts = Share.search(@query).to_a
						profiles = User.search(@query).to_a
						@results = (articles + contributors + profiles + exchanges + posts)
						search_log = SearchLog.new({
							term: @query,
							full_article_term: @query,
							all_results_count: @results.size,
							articles_results_count: articles.size,
							contributors_results_count: contributors.size,
							profiles_results_count: profiles.size,
							exchanges_results_count: exchanges.size,
							posts_results_count: posts.size
						})
						search_log.user_id = current_user.id if user_signed_in?
						search_log.save
						@latest_articles = Article.latest.limit(20) if browser.device.mobile?
						render :index_results
					end
				end
			end

			format.html do
				if !params[:query].present?
					redirect_to user_signed_in? ?  front_page_path : root_path
				end
				@sponsored_picks = Author.get_sponsors_single_posts('sponsored-pick', 1, :random)
				@trending_articles = Article.latest.limit(Author.sponsors.any? ? 4 : 5).all.to_a
				@trending_articles.insert(2, @sponsored_picks.first) if Author.sponsors.any?
				@trending_exchanges = Exchange.trending_list.all.to_a.shuffle
			end
		end
	end
end
