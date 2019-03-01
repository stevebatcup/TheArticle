module ShareHelper
	def share_info_as_json(share, has_ratings=true, show_comments=false, show_agrees=false, show_disagrees=false)
		{
			id: share.id,
			isRatings: has_ratings,
			date: share.created_at < 1.day.ago ? share.created_at.strftime("%e %b") : happened_at(share.created_at),
			commentsLoaded: false,
			opinionsLoaded: false,
			commentCount: user_signed_in? ? share.comment_count(current_user) : share.comment_count(nil),
			agreeCount: share.agree_count,
			disagreeCount: share.disagree_count,
			post: share.post,
			isOpinionatable: (share.post.length > 0) || has_ratings,
			showComments: false,
			showAgrees: false,
			showDisagrees: false,
			commentShowLimit: Comment.show_limit,
			agreeShowLimit: Opinion.show_limit,
			disagreeShowLimit: Opinion.show_limit,
			isInteractionMuted: user_signed_in? ? current_user.has_muted_own_share?(share) : false,
			user: {
				id: share.user.id,
				isMuted: user_signed_in? ? current_user.has_muted(share.user) : false,
				isBlocked: user_signed_in? ? current_user.has_blocked(share.user) : false,
				displayName: share.user.display_name,
				username: share.user.username,
				image: share.user.profile_photo.url(:square),
				path: profile_path(slug: share.user.slug),
				imFollowing: user_signed_in? ? share.user.is_followed_by(current_user) : false,
				isFollowingMe: user_signed_in? ? current_user.is_followed_by(share.user) : false
			}
		}
	end

	def share_as_json_data(user, share)
		has_ratings = share.has_ratings?
		author = share.article.author
		exchange = share.article.exchanges.first
		{
			type: has_ratings ? 'rating' : 'share',
			share: share_info_as_json(share, has_ratings),
			orderCommentsBy: :most_relevant,
			stamp: share.created_at.to_i,
			date: share.created_at < 1.day.ago ? share.created_at.strftime("%e %b") : happened_at(share.created_at),
			canInteract: user_signed_in? && share.current_user_can_interact(current_user),
			iAgreeWithPost: user_signed_in? ? share.agrees.map(&:user_id).include?(current_user.id) : false,
			iDisagreeWithPost: user_signed_in? ? share.disagrees.map(&:user_id).include?(current_user.id) : false,
			ratings: {
				wellWritten: convert_rating_to_dots(share.rating_well_written),
				wellWrittenText: text_rating(:well_written, share.rating_well_written.to_s),
				validPoints: convert_rating_to_dots(share.rating_valid_points),
				validPointsText: text_rating(:valid_points, share.rating_valid_points.to_s),
				agree: convert_rating_to_dots(share.rating_agree),
				agreeText: text_rating(:agree, share.rating_agree.to_s),
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
				remoteDomain: share.article.remote_article_domain.present? ? share.article.remote_article_domain : nil,
				image: share.article.remote_article_image_url.present? ? share.article.remote_article_image_url : share.article.image.url(:cover_mobile),
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

	def rating_labels
		{
			well_written: { '0' => 'No rating', '1' => 'Terrible', '2' => 'Poor', '3' => 'Average', '4' => 'Good', '5' => 'Excellent' },
			valid_points: { '0' => 'No rating', '1' => 'Very boring', '2' => 'Boring', '3' => 'Neutral', '4' => 'Interesting', '5' => 'Very interesting' },
			agree: { '0' => 'No rating', '1' => 'Strongly disagree', '2' => 'Disagree', '3' => 'Neutral', '4' => 'Agree', '5' => 'Strongly agree' }
		}
	end

	def text_rating(category, rating)
		rating_labels[category][rating]
	end
end