class Follow < ApplicationRecord
  has_many :feeds, as: :actionable
  has_many :notifications, as: :eventable
	belongs_to	:user
	belongs_to :followed, :class_name => "User"
	before_create	:update_feed
	# after_create	:create_notification

	def update_feed
		self.feeds.build({user_id: self.user_id})
	end

	# def create_notification
	# 	self.notifications.create({
	# 	  user_id: self.followed_id,
	# 	  specific_type: nil,
	# 	  body: "<b>#{self.user.display_name}</b> followed you",
	# 	  feed_id: self.feeds.first.id
	# 	})
	# end

	def self.users_are_connected(current_user, other_user)
		if current_user == other_user
			true
		else
			current_user.is_followed_by(other_user) && other_user.is_followed_by(current_user)
		end
	end
end