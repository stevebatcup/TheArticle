class SearchController < ApplicationController
	def index
		@query = params[:query]
		respond_to do |format|
			format.json do
				if params[:mode] == :suggestions
					if @query.present?
						@recent_searches = @who_to_follow = @trending_articles = @trending_exchanges = []
						# topics
						@topics = KeywordTag.search("*#{@query}*")
						# exchanges
						@exchanges = Exchange.search("*#{@query}*")
						# contributors
						@contributors = Author.search("*#{@query}*")
						# profiles
						if user_signed_in?
							@profiles = User.search("*#{@query}*", without: { sphinx_internal_id: current_user.id })
						else
							@profiles = User.search("*#{@query}*")
						end
					else
						@topics = @exchanges = @contributors = @profiles = []
						# recent
						@recent_searches = SearchLog.order(created_at: :desc).limit(10)
						# who to follow
						if user_signed_in? && current_user.followings.any?
							@profile_suggestions_mode = :people_might_know
							@who_to_follow = current_user.pending_suggestions.limit(10).map(&:suggested)
						else
							@profile_suggestions_mode = :who_to_follow
							@who_to_follow = User.popular_users.limit(10)
						end
						# trending articles
						@trending_articles = Article.trending.limit(10)
						# trending exchanges
						@trending_exchanges = Exchange.trending_list.limit(10).to_a.shuffle
					end
					render :index_suggestions
				elsif params[:mode] == :full
					articles = Article.search("*#{@query}*", order: 'published_at DESC').to_a
					contributors = Author.search("*#{@query}*", order: 'article_count DESC').to_a
					exchanges = Exchange.search("*#{@query}*").to_a
					posts = Share.search("*#{@query}*").to_a
					if user_signed_in?
						profiles = User.search("*#{@query}*", without: { sphinx_internal_id: current_user.id }).to_a
					else
						profiles = User.search("*#{@query}*").to_a
					end
					@results = (articles + contributors + profiles + exchanges + posts)
					search_log = SearchLog.new({
						term: @query,
						all_results_count: @results.size,
						articles_results_count: articles.size,
						contributors_results_count: contributors.size,
						profiles_results_count: profiles.size,
						exchanges_results_count: exchanges.size,
						posts_results_count: posts.size
					})
					search_log.user_id = current_user.id if user_signed_in?
					search_log.save
					render :index_results
				end
			end
			format.html do
				@sponsored_picks = Author.get_sponsors_single_posts(nil, 3)
				@trending_articles = Article.trending.limit(Author.sponsors.any? ? 4 : 5).all.to_a
				@trending_articles.insert(2, @sponsored_picks.first) if Author.sponsors.any?
				@trending_exchanges = Exchange.trending_list.all.to_a.shuffle
			end
		end
	end
end
