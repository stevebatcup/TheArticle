module OpinionHelper
	def opinion_as_json_data(opinion)
		share = opinion.share
		author = share.article.author
		exchange = share.article.exchanges.first
		{
			type: 'opinionAction',
			stamp: opinion.created_at.to_i,
			date: opinion.created_at < 1.day.ago ? opinion.created_at.strftime("%e %b") : happened_at(opinion.created_at),
			share: share_info_as_json(share, true),
			orderCommentsBy: :most_relevant,
			canInteract: user_signed_in? && share.current_user_can_interact(current_user),
			iAgreeWithPost: user_signed_in? ? share.agrees.map(&:user_id).include?(current_user.id) : false,
			iDisagreeWithPost: user_signed_in? ? share.disagrees.map(&:user_id).include?(current_user.id) : false,
			ratings: {
				wellWritten: share.rating_well_written,
				wellWrittenText: text_rating(:well_written, share.rating_well_written.to_s),
				validPoints: share.rating_valid_points,
				validPointsText: text_rating(:valid_points, share.rating_valid_points.to_s),
				agree: share.rating_agree,
				agreeText: text_rating(:agree, share.rating_agree.to_s),
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
			opinionAction: {
				date: opinion.created_at < 1.day.ago ? opinion.created_at.strftime("%e %b") : happened_at(opinion.created_at),
				action: "#{opinion.decision}d with a post by #{share.user.display_name}",
				user: {
					id: opinion.user.id,
					displayName: opinion.user.display_name,
					isMuted: user_signed_in? ? current_user.has_muted(opinion.user) : false,
					isBlocked: user_signed_in? ? current_user.has_blocked(opinion.user) : false,
					username: opinion.user.username,
					image: opinion.user.profile_photo.url(:square),
					path: profile_path(slug: opinion.user.slug),
					imFollowing: user_signed_in? ? opinion.user.is_followed_by(current_user) : false,
					isFollowingMe: user_signed_in? ? current_user.is_followed_by(opinion.user) : false
				}
			}
		}
	end
end