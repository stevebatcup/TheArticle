module ShareHelper
	def share_info_as_json(share, has_ratings=true)
		{
			id: share.id,
			isRatings: has_ratings,
			date: share.created_at.strftime("%e %b"),
			commentsLoaded: false,
			opinionsLoaded: false,
			commentCount: user_signed_in? ? share.comment_count(current_user) : share.comment_count(nil),
			agreeCount: share.agree_count,
			disagreeCount: share.disagree_count,
			post: share.post,
			showComments: false,
			showAgrees: false,
			showDisagrees: false,
			commentShowLimit: Comment.show_limit,
			agreeShowLimit: Opinion.show_limit,
			disagreeShowLimit: Opinion.show_limit,
			user: {
				id: share.user.id,
				isMuted: user_signed_in? ? current_user.has_muted(share.user) : false,
				isBlocked: user_signed_in? ? current_user.has_blocked(share.user) : false,
				displayName: share.user.display_name,
				username: share.user.username,
				image: share.user.profile_photo.url(:square),
				path: profile_path(slug: share.user.slug),
				imFollowing: share.user.is_followed_by(current_user),
				isFollowingMe: current_user.is_followed_by(share.user)
			}
		}
	end

	def share_as_json_data(user, share)
		has_ratings = share.has_ratings?
		author = share.article.author
		exchange = share.article.exchanges.first
		{
			type: has_ratings ? 'rating' : 'share',
			share: share_info_as_json(share),
			orderCommentsBy: :most_relevant,
			stamp: share.created_at.to_i,
			date: share.created_at.strftime("%e %b"),
			canInteract: user_signed_in? && share.current_user_can_interact(current_user),
			iAgreeWithPost: user_signed_in? ? share.agrees.map(&:user_id).include?(current_user.id) : false,
			iDisagreeWithPost: user_signed_in? ? share.disagrees.map(&:user_id).include?(current_user.id) : false,
			ratings: {
				wellWritten: share.rating_well_written,
				validPoints: share.rating_valid_points,
				agree: share.rating_agree,
			},
			user: {
				id: user.id,
				displayName: user.display_name,
				username: user.username,
				image: user.profile_photo.url(:square)
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
				  path: author.nil? ? '' : contributor_path(slug: author.slug),
				},
				exchange: {
					name: exchange.nil? ? '' : exchange.name,
					path: exchange.nil? ? '' : exchange_path(slug: exchange.slug),
					slug: exchange.nil? ? '' : exchange.slug,
					isSponsored: exchange.nil? ? false : exchange.slug == 'sponsored'
				}
			}
		}
	end
end