module CommentHelper
	def comment_as_json_data(comment)
		share = comment.commentable
		author = share.article.author
		exchange = share.article.exchanges.first
		{
			type: 'commentAction',
			stamp: comment.created_at.to_i,
			date: comment.created_at.strftime("%e %b"),
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
				snippet: article_excerpt_for_listing(share.article, 160),
				image: share.article.image.url(:cover_mobile),
				title: strip_tags(share.article.title),
				publishedAt: article_date(share.article),
				path: article_path(share.article),
				author: {
				  name: author.display_name,
				  path: contributor_path(slug: author.slug)
				},
				exchange: {
					name: exchange.name,
					path: exchange_path(slug: exchange.slug),
					isSponsored: exchange.slug == 'sponsored',
					slug: exchange.slug
				}
			},
			commentAction: {
				comment: comment.body,
				date: comment.created_at.strftime("%e %b"),
				action: (comment.parent_id.nil? ? "Commented on a post by #{share.user.display_name}" : "Replied to a comment by #{comment.parent.user.display_name}"),
				user: {
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
	    path: profile_path(slug: comment.user.slug),
	    displayName: comment.user.display_name,
			username: comment.user.username,
			photo: comment.user.profile_photo.url(:square),
			body: simple_format(comment.body),
			timeActual: comment.created_at.strftime("%Y-%m-%d %H:%M"),
			timeHuman: comment.created_at.strftime("%e %b"),
	    replyShowLimit: Comment.show_reply_limit
		}
	end
end