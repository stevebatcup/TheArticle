module FeedHelper
	def group_user_opinion_feed_item(item)
		results = {
			agree: [],
			disagree: []
		}
		top_item = {}
		item.feeds.each do |feed|
			opinion = feed.actionable
			result = {
				type: opinion.decision.to_sym,
				opinion: opinion,
				stamp: feed.created_at.to_i,
				user: {
					display_name: feed.user.display_name,
					username: feed.user.username,
				}
			}
			results[opinion.decision.to_sym] << result

			if top_item.empty?
				top_item = result
			elsif feed.created_at.to_i > top_item[:stamp]
				top_item = result
			end
		end

		agree_count = results[:agree].length
		disagree_count = results[:disagree].length

		sentence_opener = "<b>#{top_item[:user][:display_name]}</b> <span class='text-muted'>#{top_item[:user][:username]}</span>"
		if agree_count > 0 && disagree_count > 0
			if top_item[:type] == :agree
				if agree_count == 1
					sentence = "#{sentence_opener} agreed with a post, #{pluralize(disagree_count, 'other')} disagreed"
				else
					sentence = "#{sentence_opener} and #{pluralize(agree_count - 1, 'other')} agreed with a post, #{pluralize(disagree_count, 'other')} disagreed"
				end
			else
				if disagree_count == 1
					sentence = "#{sentence_opener} disagreed with a post, #{pluralize(agree_count, 'other')} agreed"
				else
					sentence = "#{sentence_opener} and #{pluralize(disagree_count - 1, 'other')} disagreed with a post, #{pluralize(agree_count, 'other')} agreed"
				end
			end
		elsif agree_count > 0
			if agree_count == 1
				sentence = "#{sentence_opener} agreed with a post"
			else
				sentence = "#{sentence_opener} and #{pluralize(agree_count - 1, 'other')} agreed with a post"
			end
		elsif disagree_count > 0
			if disagree_count == 1
				sentence = "#{sentence_opener} disagreed with a post"
			else
				sentence = "#{sentence_opener} and #{pluralize(disagree_count - 1, 'other')} disagreed with a post"
			end
		end

		opinion_as_json_data(top_item[:opinion], sentence)
	end

	def group_user_comment_feed_item(item)
		results = []
		top_item = {}

		item.feeds.each do |feed|
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
			sentence = "#{sentence_opener} commented on a post"
		else
			sentence = "#{sentence_opener} and #{pluralize(comments_count - 1, 'other')} commented on a post"
		end

		comment_as_json_data(top_item[:comment], sentence)
	end

	def group_user_subscription_feed_item(item)
		results = []
		top_item = {}

		item.feeds.each do |feed|
			subscription = feed.actionable
			result = {
				subscription: subscription,
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

		subscription_count = results.length
		sentence_opener = "<b>#{top_item[:user][:display_name]}</b> <span class='text-muted'>#{top_item[:user][:username]}</span>"
		if subscription_count == 1
			sentence = "#{sentence_opener} followed an exchange"
		else
			sentence = "#{sentence_opener} and #{pluralize(subscription_count - 1, 'other')} followed an exchange"
		end

		subscription_item_as_json_data(top_item[:subscription].user, top_item[:subscription], sentence)
	end
end