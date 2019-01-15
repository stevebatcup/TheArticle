class Notification < ApplicationRecord
	belongs_to	:user
	belongs_to	:eventable, polymorphic: true
	after_create	:update_user_counter_cache
	before_create	:set_is_new_and_is_seen

	def set_is_new_and_is_seen
		self.is_new = true
		self.is_seen = false
	end

	def update_user_counter_cache
		self.user.update_notification_counter_cache
	end

	# def self.get_new_count_for_user(user, grouped=true)
	# 	notifications = user.notifications.where(is_new: true)
	# end

	def self.last_weeks_for_user(current_user, weeks=4)
		current_user.notifications
								.includes(:eventable)
								.includes(:eventable)
								.where("created_at > ?", 4.weeks.ago)
	end
end
