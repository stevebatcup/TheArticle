class NotificationsController < ApplicationController
	before_action :authenticate_user!

	def index
		respond_to do |format|
			format.html do
				@sponsored_picks = Author.get_sponsors_single_posts(nil, 3)
				@trending_articles = Article.trending.limit(Author.sponsors.any? ? 4 : 5).all.to_a
				@trending_articles.insert(2, @sponsored_picks.first) if Author.sponsors.any?
				@contributors_for_spotlight = Author.contributors_for_spotlight(3)
				@recent_articles = Article.recent
				@trending_exchanges = Exchange.trending_list.all.to_a.shuffle
			end
			format.json do
				if params[:count]
					@count = current_user.notification_counter_cache
					render 'count'
				else
					page = (params[:page] || 1).to_i
					per_page = (params[:per_page] || 20).to_i
					@total_notifications = Notification.last_weeks_for_user(current_user, 4).size if page == 1
					@notifications = Notification.last_weeks_for_user(current_user, 4)
																				.order(updated_at: :desc)
																				.page(page)
																				.per(per_page)
					unless params[:panel].present?
						@notifications.each do |notification|
							notification.update_attribute(:is_new, false)
						end
						current_user.update_notification_counter_cache
					end
				end
			end
		end
	end

	def update
		@notification = Notification.find(params[:id])
		Notification.record_timestamps = false
		@notification.update_attribute(:is_seen, true)
		render json: { status: :success }
	end

	def commenters
		@notification = Notification.find(params[:id])
		@commenters = @notification.feeds.map(&:user).uniq
	end

	def opinionators
		@notification = Notification.find(params[:id])
		@opinionators = @notification.feeds.map(&:user).uniq
	end

	def followers
		@notification = Notification.find(params[:id])
		@followers = @notification.feeds.map(&:user).uniq
	end
end
