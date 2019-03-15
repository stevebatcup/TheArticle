class FrontPageController < ApplicationController
	before_action :authenticate_user!
	layout	:set_layout

	def index
		respond_to	do |format|
			format.html do
				@sponsored_picks = Author.get_sponsors_single_posts(nil, 3)
				@trending_articles = Article.latest.limit(Author.sponsors.any? ? 4 : 5).all.to_a
				@trending_articles.insert(2, @sponsored_picks.first) if Author.sponsors.any?
				@contributors_for_spotlight = Author.contributors_for_spotlight(3)
				@recent_articles = Article.recent
				@trending_exchanges = Exchange.trending_list.all.to_a.shuffle
				@latest_activity_time = Feed.latest_activity_time_for_user(current_user)
				ProfileSuggestionsGeneratorJob.perform_later(current_user, false, 15)
			end
			format.json do
				page = params[:page] || 1
				@page = page.to_i
				start_time = params[:start_time] || Time.now.to_i
				@my_exchange_ids = current_user.subscriptions.map(&:exchange_id)
				@my_followings_ids = current_user.followings.map(&:followed_id)
				@my_muted_follow_ids = current_user.follow_mutes.map(&:muted_id)
				@my_muted_exchange_ids = current_user.exchange_mutes.map(&:muted_id)
				@feeds = Feed.fetch_for_followings_of_user(current_user, false, start_time)
				@feeds += Feed.fetch_categorisations_for_user(current_user, false, start_time)
				@user_feeds = Feed.fetch_feed_user_feeds(current_user, false, start_time)
				if @page == 1
					total_feeds = Feed.fetch_for_followings_of_user(current_user, true, start_time).size
					total_categorisations = Feed.fetch_categorisations_for_user(current_user, true, start_time).length
					total_user_feeds = Feed.fetch_feed_user_feeds(current_user, true, start_time).length
					@total_feeds = total_feeds + total_categorisations + total_user_feeds
				end
			end
		end
	end
end
