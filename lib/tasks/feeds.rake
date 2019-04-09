# namespace :feeds do
# 	task :convert_shares => :environment do
# 		Feed.where(actionable_type: 'Share').each do |feed|
# 			feed.user.followers.each do |follower|
# 				unless FeedUser.find_by(action_type: 'share', source_id: feed.actionable_id, user_id: follower.id)
# 					user_feed_item = FeedUser.new({
# 						user_id: follower.id,
# 						action_type: 'share',
# 						source_id: feed.actionable_id,
# 						created_at: feed.created_at,
# 						updated_at: feed.created_at
# 					})
# 					user_feed_item.feeds << feed
# 					user_feed_item.save
# 				end
# 			end
# 		end
# 	end

# 	task :convert_categorisations => :environment do
# 		Feed.where(actionable_type: 'Categorisation').each do |feed|
# 			# puts feed.id
# 			if categorisation = Categorisation.find_by(id: feed.actionable_id)
# 				unless user_feed_item = FeedUser.find_by(action_type: 'categorisation', source_id: categorisation.article_id, user_id: feed.user_id)
# 					user_feed_item = FeedUser.new({
# 						user_id: feed.user_id,
# 						action_type: 'categorisation',
# 						source_id: categorisation.article_id,
# 						created_at: feed.created_at,
# 						updated_at: feed.created_at
# 					})
# 				end
# 				user_feed_item.feeds << feed
# 				user_feed_item.save
# 			end
# 		end
# 	end
# end
