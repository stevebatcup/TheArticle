class Notification < ApplicationRecord
	belongs_to	:user
	belongs_to	:eventable, polymorphic: true

	def self.last_weeks_for_user(current_user, weeks=4)
		current_user.notifications
								.includes(:eventable)
								.includes(:eventable)
								.where("created_at > ?", 4.weeks.ago)
	end
end
