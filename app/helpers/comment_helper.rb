module CommentHelper
	def comment_as_json_data(comment, sentence='')
		share = comment.commentable
		author = share.article.author
		exchange = share.article.exchanges.first
		sentence = "<b>#{comment.user.display_name}</b> <span class='text-muted'>#{comment.user.username}</span> commented on a post" if sentence.length == 0
		{
			type: 'commentAction',
			id: comment.id,
			stamp: comment.created_at.to_i,
			date: comment.created_at < 1.day.ago ? comment.created_at.strftime("%e %b") : happened_at(comment.created_at),
			orderCommentsBy: :most_relevant,
			share: share_info_as_json(share, true, true),
			canInteract: user_signed_in? && share.current_user_can_interact(current_user),
			actionForRetry: false,
			iAgreeWithPost: user_signed_in? ? share.agrees.map(&:user_id).include?(current_user.id) : false,
			iDisagreeWithPost: user_signed_in? ? share.disagrees.map(&:user_id).include?(current_user.id) : false,
			ratings: {
				wellWritten: convert_rating_to_dots(share.rating_well_written),
				wellWrittenText: text_rating(:well_written, share.rating_well_written),
				validPoints: convert_rating_to_dots(share.rating_valid_points),
				validPointsText: text_rating(:valid_points, share.rating_valid_points),
				agree: convert_rating_to_dots(share.rating_agree),
				agreeText: text_rating(:agree, share.rating_agree),
			},
			user: {
				displayName: share.user.display_name,
				username: share.user.username,
				image: share.user.profile_photo.url(:square),
				imFollowing: user_signed_in? ? share.user.is_followed_by(current_user) : false,
				isFollowingMe: user_signed_in? ? current_user.is_followed_by(share.user) : false
			},
			article: {
				id: share.article.id,
				isRemote: share.article.remote_article_url.present?,
				snippet: article_excerpt_for_listing(share.article, 160),
				remoteDomain: share.article.remote_article_domain.present? ? share.article.remote_article_domain : nil,
				image: share.article.remote_article_image_url.present? ? share.article.remote_article_image_url : share.article.image.url(:cover_mobile),
				title: strip_tags(share.article.title),
				publishedAt: article_date(share.article),
				path: article_path(share.article),
				author: {
				  name: author.nil? ? '' : author.display_name,
				  path: author.nil? ? '' : contributor_path(slug: author.slug)
				},
				exchange: {
					name: exchange.nil? ? '' : exchange.name,
					path: exchange.nil? ? '' : exchange_path(slug: exchange.slug),
					slug: exchange.nil? ? '' : exchange.slug,
					isSponsored: exchange.nil? ? '' : exchange.slug == 'sponsored'
				}
			},
			commentAction: {
				sentence: sentence,
				comment: comment.body.gsub(/<p> <\/p>/,""),
				date: comment.created_at < 1.day.ago ? comment.created_at.strftime("%e %b") : happened_at(comment.created_at),
				user: {
					id: comment.user.id,
					isMuted: user_signed_in? ? current_user.has_muted(comment.user) : false,
					isBlocked: user_signed_in? ? current_user.has_blocked(comment.user) : false,
					displayName: comment.user.display_name,
					username: comment.user.username,
					image: comment.user.profile_photo.url(:square),
					path: profile_path(slug: comment.user.slug),
					imFollowing: user_signed_in? ? comment.user.is_followed_by(current_user) : false,
					isFollowingMe: user_signed_in? ? current_user.is_followed_by(comment.user) : false
				}
				# action: (comment.parent_id.nil? ? "commented on a post by #{share.user.display_name}" : "replied to a comment by #{comment.parent.user.display_name}"),
			}
		}
	end

	def comment_for_tpl(comment)
		{
			id: comment.id,
			userId: comment.user.id,
	    path: profile_path(slug: comment.user.slug),
	    isMuted: user_signed_in? ? current_user.has_muted(comment.user) : false,
	    isBlocked: user_signed_in? ? current_user.has_blocked(comment.user) : false,
	    displayName: comment.user.display_name,
			username: comment.user.username,
			photo: comment.user.profile_photo.url(:square),
			body: format_comment_body(comment.body),
			timeActual: comment.created_at.strftime("%Y-%m-%d %H:%M"),
			timeHuman: comment.created_at.strftime("%e %b"),
	    replyShowLimit: Comment.show_reply_limit,
	    deleteReason: false,
	    deleteAlsoBlock: false,
	    deleteAlsoReport: false,
			imFollowing: user_signed_in? ? comment.user.is_followed_by(current_user) : false,
			isFollowingMe: user_signed_in? ? current_user.is_followed_by(comment.user) : false
		}
	end

	def format_comment_body(body)
		body = body.gsub(/<p> <\/p>/,"").html_safe
		body = remote_linkify(body, request.base_url)
		body_html =  Nokogiri::HTML.fragment(body)
		body_html.css('span.mentioned_user').each do |span|
			if span.attribute('data-display_name')
				display_name_span = Nokogiri::XML::Node.new('span', body_html)
				display_name_span['style'] = 'color: #333;'
				display_name_span.content = span.attribute('data-display_name')
				span.prepend_child "&nbsp;"
				span.prepend_child display_name_span
			end
		end
		body_html.to_html
	end
end