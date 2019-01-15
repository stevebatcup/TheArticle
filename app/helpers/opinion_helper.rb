module OpinionHelper
	def opinion_as_json_data(opinion)
		share = opinion.share
		author = share.article.author
		exchange = share.article.exchanges.first
		{
			type: 'opinionAction',
			stamp: opinion.created_at.to_i,
			date: opinion.created_at.strftime("%e %b"),
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
			opinionAction: {
				date: opinion.created_at.strftime("%e %b"),
				action: "#{opinion.decision.capitalize}d with a post by #{share.user.display_name}",
				user: {
					displayName: opinion.user.display_name,
					username: opinion.user.username,
					image: opinion.user.profile_photo.url(:square),
					path: profile_path(slug: opinion.user.slug)
				}
			}
		}
	end
end