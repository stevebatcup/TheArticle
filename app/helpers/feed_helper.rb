module FeedHelper
	def group_user_opinion_feed_item(item, for_notification=false)
		results = {
			agree: [],
			disagree: []
		}
		top_item = {}
		item.feeds.each do |feed|
			if opinion = feed.actionable
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
		end

		agree_count = results[:agree].length
		disagree_count = results[:disagree].length
		ownership = for_notification ? "your" : "a"

		sentence_opener = "<b>#{top_item[:user][:display_name]}</b> <span class='text-muted'>#{top_item[:user][:username]}</span>"
		if agree_count > 0 && disagree_count > 0
			if top_item[:type] == :agree
				if agree_count == 1
					sentence = "#{sentence_opener} agreed with #{ownership} post, <a href='#' class='also_opinionated text-green'>#{pluralize(disagree_count, 'other')}</a> disagreed"
				else
					sentence = "#{sentence_opener} and <a href='#' class='also_opinionated text-green'>#{pluralize(agree_count - 1, 'other')}</a> agreed with #{ownership} post, #{pluralize(disagree_count, 'other')} disagreed"
				end
			else
				if disagree_count == 1
					sentence = "#{sentence_opener} disagreed with #{ownership} post, <a href='#' class='also_opinionated text-green'>#{pluralize(agree_count, 'other')}</a> agreed"
				else
					sentence = "#{sentence_opener} and <a href='#' class='also_opinionated text-green'>#{pluralize(disagree_count - 1, 'other')}</a> disagreed with #{ownership} post, #{pluralize(agree_count, 'other')} agreed"
				end
			end
		elsif agree_count > 0
			if agree_count == 1
				sentence = "#{sentence_opener} agreed with #{ownership} post"
			else
				sentence = "#{sentence_opener} and <a href='#' class='also_opinionated text-green'>#{pluralize(agree_count - 1, 'other')}</a> agreed with #{ownership} post"
			end
		elsif disagree_count > 0
			if disagree_count == 1
				sentence = "#{sentence_opener} disagreed with #{ownership} post"
			else
				sentence = "#{sentence_opener} and <a href='#' class='also_opinionated text-green'>#{pluralize(disagree_count - 1, 'other')}</a> disagreed with #{ownership} post"
			end
		end

		if for_notification
			sentence
		else
			opinion_as_json_data(top_item[:opinion], sentence)
		end
	end

	def group_user_comment_feed_item(item, is_reply=false, for_notification=false)
		results = []
		top_item = {}
		user_ids = []

		item.feeds.each do |feed|
			if comment = feed.actionable
				result = {
					comment: comment,
					stamp: feed.created_at.to_i,
					user: {
						display_name: feed.user.display_name,
						username: feed.user.username,
					}
				}

				unless user_ids.include?(feed.user.id)
					user_ids << feed.user.id
					results << result

					if top_item.empty?
						top_item = result
					elsif feed.created_at.to_i > top_item[:stamp]
						top_item = result
					end
				end
			end
		end

		comments_count = results.length
		sentence_opener = "<b>#{top_item[:user][:display_name]}</b> <span class='text-muted'>#{top_item[:user][:username]}</span>"
		ownership = for_notification ? "your" : "a"
		if is_reply
			share = Share.find(item.share_id)
			poster_name = share.user.display_name
		end

		if comments_count == 1
			if is_reply
				sentence = "#{sentence_opener} replied to a comment on #{poster_name}'s post"
			else
				sentence = "#{sentence_opener} commented on #{ownership} post"
			end
		else
			others = pluralize(comments_count - 1, 'other')
			if is_reply
				sentence = "#{sentence_opener} and <a href='#' class='also_commented others_commented text-green'>#{others}</a> replied to a comment on #{poster_name}'s post"
			else
				sentence = "#{sentence_opener} and <a href='#' class='also_commented others_commented text-green'>#{others}</a> commented on #{ownership} post"
			end
		end

		if for_notification
			sentence
		else
			comment_as_json_data(top_item[:comment], sentence)
		end
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

	def group_user_follow_feed_item(item, current_user, for_notification=false)
		results = []
		top_item = {}

		item.feeds.each do |feed|
			if follow = feed.actionable
				result = {
					follow: follow,
					stamp: feed.created_at.to_i,
					user: {
						display_name: feed.user.display_name,
						username: feed.user.username,
						path: "/profile/#{feed.user.slug}"
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

		follow_count = results.length
		sentence_opener = "<a href='#{top_item[:user][:path]}'><b>#{top_item[:user][:display_name]}</b> <span class='text-muted'>#{top_item[:user][:username]}</span></a>"
		followed_path = "/profile/#{top_item[:follow].followed.slug}"
		if for_notification
			followed_name = "you"
		else
			followed_name = "<a href='#{followed_path}'><b>#{top_item[:follow].followed.display_name}</b> <span class='text-muted'>#{top_item[:follow].followed.username}</span></a>"
		end
		if follow_count == 1
			sentence = "#{sentence_opener} followed #{followed_name}"
		else
			sentence = "#{sentence_opener} and <a href='#' class='other_followers_of_user text-green'>#{pluralize(follow_count - 1, 'other')}</a> followed #{followed_name}"
		end

		if for_notification
			sentence
		else
			follow_as_json_data(top_item[:follow], current_user, sentence, 'front_page')
		end
	end
end