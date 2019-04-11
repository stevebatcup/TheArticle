class FrontPageController < ApplicationController
	before_action :authenticate_user!
	layout	:set_layout

	def index
		respond_to	do |format|
			format.html do
				@sponsored_picks = Author.get_sponsors_single_posts('sponsored-pick', 3)
				@trending_articles = Article.latest.limit(Author.sponsors.any? ? 4 : 5).all.to_a
				@trending_articles.insert(2, @sponsored_picks.first) if Author.sponsors.any?
				@contributors_for_spotlight = Author.contributors_for_spotlight(3)
				@recent_articles = Article.recent
				@trending_exchanges = Exchange.trending_list.all.to_a.shuffle
				ProfileSuggestionsGeneratorJob.perform_later(current_user, false, 15)
			end
			format.json do
				@page = (params[:page] || 1).to_i
				@per_page = (params[:per_page] || 10).to_i
				@section = params[:section]
				if (@page == 1) && (@section == 'articles')
					@latest_articles = Article.latest.limit(20)
					@sponsored_picks = Author.get_sponsors_single_posts('sponsored-pick', 20)
					@trending_exchanges = Exchange.trending_list.all.to_a.shuffle
				end
				@my_exchange_ids = current_user.subscriptions.map(&:exchange_id)
				@my_followings_ids = current_user.followings.map(&:followed_id)
				@my_muted_follow_ids = current_user.follow_mutes.map(&:muted_id)
				@my_muted_exchange_ids = current_user.exchange_mutes.map(&:muted_id)
				@feeds = Feed.fetch_user_feeds(current_user, false, @page, @per_page, @section)
				@total_feeds = Feed.fetch_user_feeds(current_user, true, @page, @per_page, @section).length if @page == 1
			end
		end
	end
end
