class SearchController < ApplicationController
	def index
		@query = params[:query]
		respond_to do |format|
			format.json do
				if params[:mode] == :suggestions
					if @query.present?
						@recent_searches = @who_to_follow = @trending_articles = @trending_exchanges = []
						# topics
						@topics = KeywordTag.search("*#{@query}*", page: 1, per_page: 5, order: 'article_count DESC')
						# exchanges
						@exchanges = Exchange.search("*#{@query}*", page: 1, per_page: 5)
						# contributors
						@contributors = Author.search(conditions: { display_name: "*#{@query}*" }, page: 1, per_page: 5)
						# profiles
						if user_signed_in?
							ids_to_exclude = [current_user.id] + current_user.blocks.map(&:blocked_id)
							@profiles = User.search(without: { sphinx_internal_id: ids_to_exclude },
																					conditions: { display_name: "*#{@query}*", status: 'active', has_completed_wizard: true },
																					page: 1, per_page: 5)
						else
							@profiles = User.search(conditions: { display_name: "*#{@query}*", status: 'active', has_completed_wizard: true },
																			page: 1, per_page: 5)
						end
					else
						@topics = @exchanges = @contributors = @profiles = []
						# recent
						# who to follow
						if user_signed_in? && current_user.followings.any?
							@recent_searches = current_user.search_logs.order(created_at: :desc).limit(5).pluck(:term).uniq
							@profile_suggestions_mode = :people_might_know
							@who_to_follow = current_user.pending_suggestions.limit(5).map(&:suggested)
						else
							@recent_searches = []
							@profile_suggestions_mode = :who_to_follow
							@who_to_follow = User.popular_users.limit(5)
						end
						# trending articles
						@trending_articles = Article.trending.limit(5)
						# trending exchanges
						@trending_exchanges = Exchange.trending_list.limit(5).to_a.shuffle
					end
					render :index_suggestions
				elsif params[:mode] == :full
					articles = Article.search("*#{@query}*", order: 'published_at DESC').to_a
					contributors = Author.search(conditions: { display_name: "*#{@query}*" },
																				order: 'article_count DESC').to_a
					exchanges = Exchange.search("*#{@query}*").to_a
					posts = Share.search("*#{@query}*").to_a
					if user_signed_in?
						profiles = User.search(without: { sphinx_internal_id: current_user.id },
																		conditions: { display_name: "*#{@query}*", status: 'active', has_completed_wizard: true },
																		page: 1, per_page: 5).to_a
					else
						profiles = User.search(conditions: { display_name: "*#{@query}*", status: 'active', has_completed_wizard: true },
																		page: 1, per_page: 5).to_a
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
				if !params[:query].present?
					redirect_to user_signed_in? ?  front_page_path : root_path
				end
				@sponsored_picks = Author.get_sponsors_single_posts(nil, 3)
				@trending_articles = Article.latest.limit(Author.sponsors.any? ? 4 : 5).all.to_a
				@trending_articles.insert(2, @sponsored_picks.first) if Author.sponsors.any?
				@trending_exchanges = Exchange.trending_list.all.to_a.shuffle
			end
		end
	end
end
