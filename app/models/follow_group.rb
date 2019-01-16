class FollowGroup < ApplicationRecord
	has_many	:follows
  has_many :notifications, as: :eventable
	after_create	:create_notification
	belongs_to	:user

	def create_notification
		self.notifications.create({
		  user_id: self.user_id,
		  body: self.body,
		  feed_id: nil,
		  specific_type: nil,
		})
	end

	def self.generate_body_text_from_followings(follows)
		person = follows.first.user.display_name
		count = follows.length - 1
		countSentence = count == 1 ? "#{count} other" : "#{count} others"
		sentence = count > 0 ? "<b>#{person}</b> and #{countSentence} followed you" : "<b>#{person}</b> followed you"
	end
end
