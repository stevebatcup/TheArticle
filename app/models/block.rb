class Block < ApplicationRecord
	belongs_to	:user
	belongs_to	:blocked, class_name: 'User'
	after_create	:delete_followings

	def delete_followings
		follower = User.find(self.user_id)
		if followThem = follower.followings.find_by(followed_id: self.blocked_id)
			followThem.destroy
		end

		followed = User.find(self.blocked_id)
		if followMe = followed.followings.find_by(followed_id: self.user_id)
			followMe.destroy
		end
	end
end
