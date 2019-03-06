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
			end
			format.json do
				page = params[:page] || 1
				page = page.to_i
				per_page = 10
				@my_exchange_ids = current_user.subscriptions.map(&:exchange_id)
				@my_followings_ids = current_user.followings.map(&:followed_id)
				@my_muted_follow_ids = current_user.follow_mutes.map(&:muted_id)
				@my_muted_exchange_ids = current_user.exchange_mutes.map(&:muted_id)
				@feeds = Feed.fetch_for_followings_of_user(current_user, page, per_page)
				@feeds += Feed.fetch_categorisations_for_user(current_user, page, per_page)
				@user_feeds = current_user.feed_users.order(updated_at: :desc).page(page).per(per_page)
				if page == 1
					total_feeds = Feed.fetch_for_followings_of_user(current_user, 1, 0).size
					total_categorisations = Feed.fetch_categorisations_for_user(current_user, 1, 0).size
					total_user_feeds = current_user.feed_users.size
					@total_feeds = total_feeds + total_categorisations + total_user_feeds
				end
				@page = page
				@suggestions = []#current_user.paginated_pending_suggestions(page, 2)
			end
		end
	end
end
