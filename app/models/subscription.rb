class Subscription < ApplicationRecord
  has_many :feeds, as: :actionable
	belongs_to	:user
	belongs_to	:exchange
	after_create	:update_feed
	after_destroy	:delete_feed

	def update_feed
		feed = self.feeds.build({user_id: self.user_id})
		self.user.followers.each do |follower|
			unless user_feed_item = FeedUser.find_by(user_id: follower.id, action_type: 'subscription', source_id: self.exchange_id)
				user_feed_item = FeedUser.new({
					user_id: follower.id,
					action_type: 'subscription',
					source_id: self.exchange_id
				})
			end
			user_feed_item.feeds << feed
			user_feed_item.save
		end
		build_retrospective_feeds
	end

	def build_retrospective_feeds
		self.exchange.categorisations.each do |categorisation|
			if categorisation.article
				feed = Feed.new({actionable_id: categorisation.id, actionable_type: 'Categorisation'})
				self.user.feeds << feed
				unless user_feed_item = FeedUser.find_by(user_id: self.user.id, action_type: 'categorisation', source_id: categorisation.article_id)
					user_feed_item = FeedUser.new({
						user_id: self.user.id,
						action_type: 'categorisation',
						source_id: categorisation.article_id
					})
				end
				user_feed_item.created_at = Time.now unless user_feed_item.persisted?
				user_feed_item.updated_at = categorisation.article.published_at
				user_feed_item.feeds << feed
				user_feed_item.save
			end
		end
		self.user.save
	end

	def delete_feed
		self.feeds.where({user_id: self.user_id}).destroy_all
		delete_retrospective_feeds
	end

	def delete_retrospective_feeds
		self.exchange.categorisations.each do |categorisation|
			if feed = self.user.feeds.where(actionable_id: categorisation.id, actionable_type: 'Categorisation').first
				feed.destroy
			end
			if user_feed_item = FeedUser.find_by(user_id: self.user.id, action_type: 'categorisation', source_id: categorisation.article.id)
				user_feed_item.destroy
			end
		end
	end

	def self.table_name
		'exchanges_users'
	end
end