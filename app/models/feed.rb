class Feed < ApplicationRecord
	belongs_to	:user
	has_and_belongs_to_many	:feed_user, dependent: :destroy
	has_and_belongs_to_many	:notifications
	belongs_to	:actionable, polymorphic: true

	def self.per_page
		10
	end

	def self.fetch_user_feeds(current_user, count_only=false, page=1, section='articles')
		case section
		when 'articles'
			actions = ['categorisation', 'subscription']
		when 'posts'
			actions = ['share', 'comment', 'opinion']
		when 'follows'
			actions = ['follow']
		end
		results = current_user.feed_users
													.select("COUNT(feeds.id) AS feed_count, feed_users.*")
													.left_outer_joins(:feeds)
													.where("feeds.id IS NOT NULL")
													.where(action_type: actions)
													.group("feed_users.id")
													.order(updated_at: :desc)
		results = results.having("feed_count > 1") if section == 'follows'
		results = results.page(page).per(per_page) unless count_only
		results
	end
end
