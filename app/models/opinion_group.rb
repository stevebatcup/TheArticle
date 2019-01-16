class OpinionGroup < ApplicationRecord
	has_many	:opinions
  has_many :notifications, as: :eventable
  belongs_to	:user
  belongs_to	:share
	after_create	:create_notification

	def create_notification
	  self.notifications.create({
	    user_id: self.user_id,
	    specific_type: self.decision,
	    body: self.body,
	    feed_id: nil
	  })
	end

	def self.generate_body_text_from_opinions(opinions, decision=:agree)
		person = opinions.first.user.display_name
		count = opinions.length - 1
		countSentence = count == 1 ? "#{count} other" : "#{count} others"
		sentence = count > 0 ? "<b>#{person}</b> and #{countSentence} #{decision.to_s}d with your post" : "<b>#{person}</b> #{decision.to_s}d with your post"
	end
end
