module CommentHelper
	def comment_as_json_data(comment)
		share = comment.commentable
		author = share.article.author
		exchange = share.article.exchanges.first
		{
			type: 'commentAction',
			id: comment.id,
			stamp: comment.created_at.to_i,
			date: comment.created_at.strftime("%e %b"),
			orderCommentsBy: :most_relevant,
			share: share_info_as_json(share, true),
			canInteract: user_signed_in? && share.current_user_can_interact(current_user),
			iAgreeWithPost: user_signed_in? ? share.agrees.map(&:user_id).include?(current_user.id) : false,
			iDisagreeWithPost: user_signed_in? ? share.disagrees.map(&:user_id).include?(current_user.id) : false,
			ratings: {
				wellWritten: share.rating_well_written,
				validPoints: share.rating_valid_points,
				agree: share.rating_agree
			},
			user: {
				displayName: share.user.display_name,
				username: share.user.username,
				image: share.user.profile_photo.url(:square)
			},
			article: {
				id: share.article.id,
				isRemote: share.article.remote_article_url.present?,
				snippet: article_excerpt_for_listing(share.article, 160),
				image: share.article.image.url(:cover_mobile),
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
				comment: comment.body,
				date: comment.created_at.strftime("%e %b"),
				action: (comment.parent_id.nil? ? "Commented on a post by #{share.user.display_name}" : "Replied to a comment by #{comment.parent.user.display_name}"),
				user: {
					id: comment.user.id,
					isMuted: user_signed_in? ? current_user.has_muted(comment.user) : false,
					isBlocked: user_signed_in? ? current_user.has_blocked(comment.user) : false,
					displayName: comment.user.display_name,
					username: comment.user.username,
					image: comment.user.profile_photo.url(:square),
					path: profile_path(slug: comment.user.slug)
				}
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
			body: comment.body,
			timeActual: comment.created_at.strftime("%Y-%m-%d %H:%M"),
			timeHuman: comment.created_at.strftime("%e %b"),
	    replyShowLimit: Comment.show_reply_limit
		}
	end
end