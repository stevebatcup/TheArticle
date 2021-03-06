module ShareHelper
	def share_info_as_json(share, has_ratings=true, show_comments=false, show_agrees=false, show_disagrees=false)
		{
			id: share.id,
			isRatings: has_ratings,
			actualDate: event_date_formatted(share.created_at),
			date: share.created_at < 1.day.ago ? event_date_formatted(share.created_at) : happened_at(share.created_at),
			commentsLoaded: false,
			opinionsLoaded: false,
			commentCount: user_signed_in? ? share.comment_count(current_user) : share.comment_count(nil),
			agreeCount: share.agree_count,
			disagreeCount: share.disagree_count,
			post: format_post(share.post),
			isOpinionatable: (share.post.length > 0) || has_ratings,
			showComments: false,
			showAgrees: false,
			showDisagrees: false,
			commentShowLimit: Comment.show_limit,
			agreeShowLimit: Opinion.show_limit,
			disagreeShowLimit: Opinion.show_limit,
			isInteractionMuted: user_signed_in? ? current_user.has_muted_own_share?(share) : false,
			ownership: user_signed_in? && share.user.id == current_user.id ? "Your" : "#{share.user.display_name}'s",
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
			date: share.created_at < 1.day.ago ? event_date_formatted(share.created_at) : happened_at(share.created_at),
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
				id: user.id,
				displayName: user.display_name,
				username: user.username,
				image: user.profile_photo.url(:square),
				path: profile_path(slug: user.slug)
			},
			article: {
				id: share.article.id,
				isRemote: share.article.remote_article_url.present?,
				snippet: article_excerpt_for_listing(share.article, 160),
				remoteDomain: share.article.remote_article_domain.present? ? share.article.remote_article_domain : nil,
				image: share.article.remote_article_image_url.present? ? share.article.remote_article_image_url : share.article.image.url(:cover_mobile),
				title: strip_tags(share.article.title),
				publishedAt: article_date(share.article),
				url: full_article_url(share.article),
				path: article_path(share.article),
				author: {
				  name: author.nil? ? '' : author.display_name,
				  path: author.nil? ? '' : contributor_path(slug: author.slug),
				},
				exchange: {
					id: exchange.nil? ? '' : exchange.id,
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
			well_written: { '0' => 'Not yet rated', '1' => 'Terrible', '2' => 'Poor', '3' => 'Average', '4' => 'Good', '5' => 'Excellent' },
			valid_points: { '0' => 'Not yet rated', '1' => 'Very boring', '2' => 'Boring', '3' => 'Neutral', '4' => 'Interesting', '5' => 'Very interesting' },
			agree: { '0' => 'Not yet rated', '1' => 'Strongly disagree', '2' => 'Disagree', '3' => 'Neutral', '4' => 'Agree', '5' => 'Strongly agree' }
		}
	end

	def rating_classes
		{
			well_written: { '0' => 'not_yet_rated', '1' => 'terrible', '2' => 'poor', '3' => 'average', '4' => 'good', '5' => 'excellent' },
			valid_points: { '0' => 'not_yet_rated', '1' => 'very_boring', '2' => 'boring', '3' => 'neutral', '4' => 'interesting', '5' => 'very_interesting' },
			agree: { '0' => 'not_yet_rated', '1' => 'strongly_disagree', '2' => 'disagree', '3' => 'neutral', '4' => 'agree', '5' => 'strongly_agree' }
		}
	end

	def text_rating(category, rating)
		key = convert_rating_to_dots(rating).to_s
		rating_labels[category][key]
	end

	def format_post(post)
		post_html =  Nokogiri::HTML.fragment(post)
		post_html.css('span.mentioned_user').each do |span|
			if span.attribute('data-display_name')
				display_name_span = Nokogiri::XML::Node.new('span', post_html)
				display_name_span['style'] = 'color: #333;'
				display_name_span.content = span.attribute('data-display_name')
				span.prepend_child "&nbsp;"
				span.prepend_child display_name_span
			end
		end
		post_html.to_html
	end
end