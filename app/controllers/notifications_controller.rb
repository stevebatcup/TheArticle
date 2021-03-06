class NotificationsController < ApplicationController
	before_action :authenticate_user!

	def index
		respond_to do |format|
			format.html do
				# redirect_to front_page_path(route: :notifications) if browser.device.mobile?
				@sponsored_picks = Author.get_sponsors_single_posts('sponsored-pick', 1, :random)
				@trending_articles = Article.latest.limit(Author.sponsors.any? ? 4 : 5).all.to_a
				@trending_articles.insert(2, @sponsored_picks.first) if Author.sponsors.any?
				@contributors_for_spotlight = Author.contributors_for_spotlight(3)
				@trending_exchanges = Exchange.trending_list.all.to_a.shuffle
				current_user.set_all_notifications_as_old
			end
			format.json do
				if params[:count]
					Rails.logger.silence do
						@count = current_user.notification_counter_cache
						render 'count'
					end
				else
					page = (params[:page] || 1).to_i
					per_page = (params[:per_page] || 20).to_i
					@total_notifications = current_user.notifications.size if page == 1
					@notifications = current_user.notifications
																				.includes(:eventable)
																				.order(updated_at: :desc)
																				.page(page)
																				.per(per_page)
					unless params[:panel].present?
						@notifications.each do |notification|
							Notification.record_timestamps = false
							notification.update_attribute(:is_new, false) if notification.is_new
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
		opinionators = []
		@notification.feeds.each do |feed|
			opinion = feed.actionable
			if opinion.decision == params[:decision]
				opinionators << feed.user
			end
		end
		@opinionators = opinionators.reverse.uniq
	end

	def followers
		@notification = Notification.find(params[:id])
		@followers = @notification.feeds.map(&:user).uniq
	end
end
