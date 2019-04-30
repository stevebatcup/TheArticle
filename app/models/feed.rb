class Feed < ApplicationRecord
	belongs_to	:user
	has_and_belongs_to_many	:feed_user, dependent: :destroy
	has_and_belongs_to_many	:notifications
	belongs_to	:actionable, polymorphic: true

	def self.fetch_user_feeds(current_user, count_only=false, page=1, per_page=10, section='articles')
		results = current_user.feed_users
													.select("COUNT(feeds.id) AS feed_count, feed_users.*")
													.left_outer_joins(:feeds)
													.where("feeds.id IS NOT NULL")
													.group("feed_users.id")
													.order(updated_at: :desc)

		if section == 'articles'
			user_exchange_ids = current_user.subscriptions.map(&:exchange_id)
			user_muted_exchange_ids = current_user.exchange_mutes.map(&:muted_id)
			results = results.where("(action_type = 'categorisation') OR (
				(action_type = 'subscription')
					AND
					(source_id NOT IN ('#{user_exchange_ids.join("', '")}'))
					AND
					(source_id NOT IN ('#{user_muted_exchange_ids.join("', '")}'))
				)")
		elsif section == 'posts'
			actions = ['share', 'comment', 'opinion']
			results = results.where(action_type: actions)
		elsif section == 'follows'
			user_followings_ids = current_user.followings.map(&:followed_id)
			user_muted_follow_ids = current_user.follow_mutes.map(&:muted_id)
			results = results.where(action_type: "follow")
											.where.not(source_id: user_followings_ids)
											.where.not(source_id: user_muted_follow_ids)
											.having("feed_count > 1")
		end

		results = results.page(page).per(per_page) unless count_only
		results
	end
end
