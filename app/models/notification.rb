class Notification < ApplicationRecord
	belongs_to	:user
	belongs_to	:eventable, polymorphic: true
	after_create	:update_user_counter_cache
	before_create	:set_is_new_and_is_seen
	has_and_belongs_to_many	:feeds

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

	def self.write_body_for_comment_set(notification)
		results = []
		top_item = {}

		notification.feeds.each do |feed|
			comment = feed.actionable
			result = {
				comment: comment,
				stamp: feed.created_at.to_i,
				user: {
					display_name: feed.user.display_name,
					username: feed.user.username,
				}
			}
			results << result

			if top_item.empty?
				top_item = result
			elsif feed.created_at.to_i > top_item[:stamp]
				top_item = result
			end
		end

		comments_count = results.length
		sentence_opener = "<b>#{top_item[:user][:display_name]}</b> <span class='text-muted'>#{top_item[:user][:username]}</span>"
		if comments_count == 1
			"#{sentence_opener} commented on your post"
		else
			others = ApplicationController.helpers.pluralize(comments_count - 1, 'other')
			"#{sentence_opener} and #{others} commented on your post"
		end
	end
end
