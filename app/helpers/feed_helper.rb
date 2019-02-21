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
			sentence = "#{sentence_opener} and <a href='#' class='also_commented'>#{pluralize(comments_count - 1, 'other')}</a> commented on a post"
		end

		comment_as_json_data(top_item[:comment], sentence)
	end

	def group_user_subscription_feed_item(item)
		results = []
		top_item = {}

		item.feeds.each do |feed|
			if subscription = feed.actionable
				result = {
					feed_id: feed.id,
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
		end

		subscription_count = results.length
		sentence_opener = "<b>#{top_item[:user][:display_name]}</b> <span class='text-muted'>#{top_item[:user][:username]}</span>"
		if subscription_count == 1
			sentence = "#{sentence_opener} followed an exchange"
		else
			sentence = "#{sentence_opener} and <a href='#' class='other_followers_of_exchange text-green'>#{pluralize(subscription_count - 1, 'other')}</a> followed an exchange"
		end

		subscription_item_as_json_data(top_item[:subscription].user, top_item[:subscription], sentence, 'front_page')
	end

	def group_user_follow_feed_item(item)
		results = []
		top_item = {}

		item.feeds.each do |feed|
			follow = feed.actionable
			result = {
				follow: follow,
				stamp: feed.created_at.to_i,
				user: {
					display_name: feed.user.display_name,
					username: feed.user.username,
					path: profile_path(slug: feed.user.slug)
				}
			}
			results << result

			if top_item.empty?
				top_item = result
			elsif feed.created_at.to_i > top_item[:stamp]
				top_item = result
			end
		end

		follow_count = results.length
		sentence_opener = "<a href='#{top_item[:user][:path]}'><b>#{top_item[:user][:display_name]}</b> <span class='text-muted'>#{top_item[:user][:username]}</span></a>"
		followed_path = profile_path(slug: top_item[:follow].followed.slug)
		followed_name = "<a href='#{followed_path}'><b>#{top_item[:follow].followed.display_name}</b> <span class='text-muted'>#{top_item[:follow].followed.username}</span></a>"
		if follow_count == 1
			sentence = "#{sentence_opener} followed #{followed_name}"
		else
			sentence = "#{sentence_opener} and <a href='#' class='other_followers_of_user text-green'>#{pluralize(follow_count - 1, 'other')}</a> followed #{followed_name}"
		end

		follow_as_json_data(top_item[:follow], current_user, sentence, 'front_page')
	end
end