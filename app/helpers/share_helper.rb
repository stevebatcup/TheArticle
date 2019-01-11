module ShareHelper
	def share_as_json_data(user, share)
		has_ratings = share.has_ratings?
		author = share.article.author
		exchange = share.article.exchanges.first
		{
			type: has_ratings ? 'rating' : 'share',
			share: share.json_data(has_ratings),
			stamp: share.created_at.to_i,
			canInteract: user_signed_in? && share.current_user_can_interact(current_user),
			iAgreeWithPost: user_signed_in? ? share.agrees.map(&:user_id).include?(current_user.id) : false,
			iDisagreeWithPost: user_signed_in? ? share.disagrees.map(&:user_id).include?(current_user.id) : false,
			ratings: {
				wellWritten: share.rating_well_written,
				validPoints: share.rating_valid_points,
				agree: share.rating_agree,
			},
			user: {
				displayName: user.display_name,
				username: user.username,
				image: user.profile_photo.url(:square)
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
				  path: contributor_path(slug: author.slug),
				},
				exchange: {
					name: exchange.name,
					path: exchange_path(slug: exchange.slug),
					isSponsored: exchange.slug == 'sponsored',
					slug: exchange.slug
				}
			}
		}
	end
end