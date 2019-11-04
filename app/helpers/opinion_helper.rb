module OpinionHelper
	def opinion_as_json_data(opinion, sentence='')
		share = opinion.share
		author = share.article.author
		exchange = share.article.exchanges.first
		show_agrees = opinion.decision == 'agree'
		show_disagrees = opinion.decision == 'disagree'
		sentence = "<b>#{opinion.user.display_name}</b> <span class='text-muted'>#{opinion.user.username}</span> #{opinion.decision}d with a post" if sentence.length == 0
		{
			type: 'opinionAction',
			stamp: opinion.created_at.to_i,
			date: opinion.created_at < 1.day.ago ? opinion.created_at.strftime("%e %b") : happened_at(opinion.created_at),
			share: share_info_as_json(share, true, false, show_agrees, show_disagrees),
			orderCommentsBy: :most_relevant,
			canInteract: user_signed_in? && share.current_user_can_interact(current_user),
			iAgreeWithPost: user_signed_in? ? share.agrees.map(&:user_id).include?(current_user.id) : false,
			iDisagreeWithPost: user_signed_in? ? share.disagrees.map(&:user_id).include?(current_user.id) : false,
			ratings: {
				wellWritten: convert_rating_to_dots(share.rating_well_written),
				wellWrittenText: text_rating(:well_written, share.rating_well_written),
				wellWrittenClass: text_rating(:well_written, share.rating_well_written).parameterize.underscore,
				validPoints: convert_rating_to_dots(share.rating_valid_points),
				validPointsText: text_rating(:valid_points, share.rating_valid_points),
				validPointsClass: text_rating(:valid_points, share.rating_valid_points).parameterize.underscore,
				agree: convert_rating_to_dots(share.rating_agree),
				agreeText: text_rating(:agree, share.rating_agree),
				agreeClass: text_rating(:agree, share.rating_agree).parameterize.underscore
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
			opinionAction: {
				sentence: sentence,
				date: opinion.created_at < 1.day.ago ? opinion.created_at.strftime("%e %b") : happened_at(opinion.created_at),
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
				# action: "#{opinion.decision}d with a post by #{share.user.display_name}",
			}
		}
	end
end