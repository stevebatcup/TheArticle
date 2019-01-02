class SearchController < ApplicationController
	def index
		@query = params[:query]
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
				@profiles = User.search("*#{@query}*")
			else
				@topics = @exchanges = @contributors = @profiles = []
				# recent
				@recent_searches = SearchLog.order(created_at: :desc).limit(10)
				# who to follow
				if user_signed_in? && current_user.followings.any?
					@profile_suggestions_mode = :people_might_know
					@who_to_follow = current_user.pending_suggestions.limit(10)
				else
					@profile_suggestions_mode = :who_to_follow
					@who_to_follow = User.popular_users.limit(10)
				end
				# trending articles
				@trending_articles = Article.trending.limit(10)
				# trending exchanges
				@trending_exchanges = Exchange.trending_list.limit(10).to_a.shuffle
			end
		elsif params[:mode] == :full
			# articles
			# @articles = Article.search(params[:query], match_mode: :boolean)
			# @contributors_for_spotlight = Author.contributors_for_spotlight
			# @recent_articles = Article.recent
		end
	end
end
