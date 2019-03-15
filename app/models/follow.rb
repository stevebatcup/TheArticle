class Follow < ApplicationRecord
  has_many :feeds, as: :actionable
	belongs_to	:user
	belongs_to :followed, :class_name => "User"
	belongs_to	:follow_group, optional: true
	after_create	:update_feeds
	after_create	:create_notification
	after_destroy	:delete_feed_and_regenerate_notification

	def update_feeds
		# feed for this follow (to appear on my followers homepage)
		feed = self.feeds.build({user_id: self.user_id})
		self.user.followers.each do |follower|
			unless user_feed_item = FeedUser.find_by(user_id: follower.id, action_type: 'follow', source_id: self.followed_id)
				user_feed_item = FeedUser.new({
					user_id: follower.id,
					action_type: 'follow',
					source_id: self.followed_id
				})
			end
			user_feed_item.created_at = Time.now unless user_feed_item.persisted?
			user_feed_item.updated_at = Time.now
			user_feed_item.feeds << feed
			user_feed_item.save
		end

		# feeds for opinions/comments made by newly followed user (to appear on the followers homepage)
		current_user = User.find(self.user_id)
		interactor = User.find(self.followed_id)
		build_retrospective_opinion_feed(interactor, current_user)
		build_retrospective_comment_feed(interactor, current_user)
		build_retrospective_subscription_feed(interactor, current_user)
	end

	def build_retrospective_opinion_feed(opinionator, current_user)
		opinionator.feeds.where(actionable_type: 'Opinion').each do |opinion_feed|
			if opinion_feed.actionable
				share_id = opinion_feed.actionable.share_id
				unless user_feed_item = FeedUser.find_by(user_id: current_user.id, action_type: 'opinion', source_id: share_id)
					user_feed_item = FeedUser.new({
						user_id: current_user.id,
						action_type: 'opinion',
						source_id: share_id
					})
				end
				user_feed_item.created_at = opinion_feed.actionable.created_at unless user_feed_item.persisted?
				user_feed_item.updated_at = opinion_feed.actionable.created_at
				user_feed_item.feeds << opinion_feed
				user_feed_item.save
			end
		end
	end

	def build_retrospective_comment_feed(commentor, current_user)
		commentor.feeds.where(actionable_type: 'Comment').each do |comment_feed|
			if comment_feed.actionable
				share_id = comment_feed.actionable.commentable_id
				unless user_feed_item = FeedUser.find_by(user_id: current_user.id, action_type: 'comment', source_id: share_id)
					user_feed_item = FeedUser.new({
						user_id: current_user.id,
						action_type: 'comment',
						source_id: share_id
					})
				end
				user_feed_item.created_at = comment_feed.actionable.created_at unless user_feed_item.persisted?
				user_feed_item.updated_at = comment_feed.actionable.created_at
				user_feed_item.feeds << comment_feed
				user_feed_item.save
			end
		end
	end

	def build_retrospective_subscription_feed(subscriber, current_user)
		subscriber.feeds.where(actionable_type: 'Subscription').each do |subscription_feed|
			if subscription_feed.actionable
				exchange_id = subscription_feed.actionable.exchange_id
				unless user_feed_item = FeedUser.find_by(user_id: current_user.id, action_type: 'subscription', source_id: exchange_id)
					user_feed_item = FeedUser.new({
						user_id: current_user.id,
						action_type: 'subscription',
						source_id: exchange_id
					})
				end
				user_feed_item.created_at = subscription_feed.actionable.created_at unless user_feed_item.persisted?
				user_feed_item.updated_at = subscription_feed.actionable.created_at
				user_feed_item.feeds << subscription_feed
				user_feed_item.save
			end
		end
	end

	def create_notification
		notification = Notification.where(eventable_type: 'Follow')
										.where(user_id: self.followed_id)
										.where("DATE(created_at) = CURDATE()")
										.first()
		if notification.nil?
			notification = Notification.new({
				eventable_type: 'Follow',
				user_id: self.followed_id,
				created_at: Time.now,
				updated_at: Time.now
			})
		end
		notification.eventable_id = self.id
		notification.feeds << self.feeds.first
		notification.body = ApplicationController.helpers.group_user_follow_feed_item(notification, self.user, true)
		notification.save
	end

	def delete_feed_and_regenerate_notification
		self.feeds.destroy_all
		if notification = Notification.where(eventable_type: 'Follow')
										.where(user_id: self.followed_id)
										.where("DATE(created_at) = CURDATE()")
										.first()
			if notification.feeds.any?
				new_body = ApplicationController.helpers.group_user_follow_feed_item(notification, self.user, true)
				notification.update_attribute(:body, new_body)
			else
				notification.destroy
			end
		end
	end

	def self.users_are_connected(current_user, other_user)
		if current_user == other_user
			true
		else
			current_user.is_followed_by(other_user) && other_user.is_followed_by(current_user)
		end
	end

	def self.both_directions_for_user(user)
		where(user_id: user.id).or(where(followed_id: user.id))
	end
end