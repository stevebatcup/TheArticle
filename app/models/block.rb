class Block < ApplicationRecord
	belongs_to	:user
	belongs_to	:blocked, class_name: 'User'
	after_create	:delete_followings

	def self.active
		where(status: :active)
	end

	def delete_followings
		follower = User.find(self.user_id)
		if followThem = follower.followings.find_by(followed_id: self.blocked_id)
			followThem.destroy
		end

		followed = User.find(self.blocked_id)
		if followMe = followed.followings.find_by(followed_id: self.user_id)
			followMe.destroy
		end
		delete_activity(follower, followed)
	end

	def delete_activity(me, them)
		# delete their interactions with my posts/comments
		my_share_ids = me.shares.map(&:id)
		them.opinions.where(share_id: my_share_ids).destroy_all
		them.comments.where(commentable_id: my_share_ids).where(commentable_type: 'Share').destroy_all

		# delete my interactions with their posts/comments
		their_share_ids = them.shares.map(&:id)
		me.opinions.where(share_id: their_share_ids).destroy_all
		me.comments.where(commentable_id: their_share_ids).where(commentable_type: 'Share').destroy_all
	end
end
