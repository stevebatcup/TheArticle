class Feed < ApplicationRecord
	belongs_to	:user
	belongs_to	:actionable, polymorphic: true

	def self.types_for_followings
		['Share', 'Comment', 'Subscription', 'Follow', 'Opinion']
	end

	def self.types_for_user
		['Categorisation']
	end

	def self.fetch_for_followings_of_user(user, page=1, per_page=25)
		muted_list = user.mutes.where(status: :active).map(&:muted_id)
		blocked_list = user.blocks.where(status: :active).map(&:blocked_id)
		followings_map = user.followings.where.not(followed_id: muted_list).where.not(followed_id: blocked_list).map(&:followed_id)
		feed = self.where(user_id: followings_map, actionable_type: self.types_for_followings)
					.or(self.where(user_id: user.id, actionable_type: self.types_for_user))
					.order(created_at: :desc)
		feed = feed.page(page).per(per_page) if per_page > 0
		feed
	end
end
