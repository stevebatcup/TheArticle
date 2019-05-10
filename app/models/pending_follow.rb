class PendingFollow < ApplicationRecord
	def self.process_for_user(user)
		pending_follows = self.where(user_id: user.id)
		if pending_follows.any?
			pending_follows.each do |pf|
				pf.process
			end
		end
	end

	def process
		if follow = Follow.find(self.follow_id)
			current_user = User.find(follow.user_id)
			other_user = User.find(follow.followed_id)
			follow.update_feeds
			follow.create_notification
			follow.update_follow_counts_for_both_users
			other_user.send_followed_mail_if_opted_in(current_user)
		end
		self.destroy
	end
end
