json.set! :profile do
	json.isSignedIn user_signed_in?

	# basics
	json.id @user.id
	json.isNew true
	json.joinedAt	@user.created_at.strftime("%B %Y")

	# text
	displayName = @user.display_name
	json.displayName displayName

	fullUsername = @user.username
	json.username fullUsername[1..-1]
	json.originalUsername fullUsername

	json.location @user.location
	json.bio @user.bio
	userPath = profile_path(slug: @user.slug)

	# photos
	profileImage = @user.profile_photo.url(:square)
	json.profilePhoto do
		json.image profileImage
		json.source ""
	end
	json.coverPhoto do
		json.image @user.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
		json.source ""
	end

	recentFollowingSummary = following_summary(@user.recent_followings(48))
	json.recentFollowingSummary do
		json.stamp recentFollowingSummary[:stamp]
		json.date recentFollowingSummary[:date]
		json.sentence recentFollowingSummary[:sentence].present? ? recentFollowingSummary[:sentence].html_safe : ''
		json.user do
			json.path userPath
			json.image profileImage
			json.displayName displayName
			json.username fullUsername
		end
	end

	recentFollowedSummary  = following_summary(@user.recent_followeds(48), "followed")
	json.recentFollowedSummary do
		json.stamp recentFollowedSummary[:stamp]
		json.date recentFollowedSummary[:date]
		json.sentence recentFollowedSummary[:sentence].present? ? recentFollowedSummary[:sentence].html_safe : ''
		json.user do
			json.path userPath
			json.image profileImage
			json.displayName displayName
			json.username fullUsername
		end
	end

	# follows
	json.imFollowing user_signed_in? ? @user.is_followed_by(current_user) : false
	json.set! :followers do
		json.array! @user.followers do |follower|
			json.id follower.id
			json.path profile_path(slug: follower.slug)
			json.displayName follower.display_name
			json.username follower.username
			json.bio bio_excerpt(follower, browser.device.mobile? ? 9 : 28)
			json.profilePhoto follower.profile_photo.url(:square)
			json.coverPhoto follower.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
			json.imFollowing user_signed_in? ? follower.is_followed_by(current_user) : false
			json.isFollowingMe user_signed_in? ? current_user.is_followed_by(follower) : false
		end
	end

	json.set! :followings do
		json.array! @user.followings do |following|
			json.id following.followed_id
			json.path profile_path(slug: following.followed.slug)
			json.displayName following.followed.display_name
			json.username following.followed.username
			json.bio bio_excerpt(following.followed, browser.device.mobile? ? 9 : 28)
			json.profilePhoto following.followed.profile_photo.url(:square)
			json.coverPhoto following.followed.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
			json.imFollowing user_signed_in? ? following.followed.is_followed_by(current_user) : false
			json.isFollowingMe user_signed_in? ? current_user.is_followed_by(following.followed) : false
		end
	end

	json.set! :shares do
		json.array! @user.share_onlys do |share|
			json.stamp share.created_at.to_i
			json.share share_info_as_json(share, false)
			json.canInteract user_signed_in? && share.current_user_can_interact(current_user)
			json.iAgreeWithPost user_signed_in? ? share.agrees.map(&:user_id).include?(current_user.id) : false
			json.iDisagreeWithPost user_signed_in? ? share.disagrees.map(&:user_id).include?(current_user.id) : false
			json.set! :user do
				json.displayName displayName
				json.username fullUsername
				json.image profileImage
			end
			json.set! :article do
				json.id share.article.id
				json.snippet article_excerpt_for_listing(share.article, 160)
				json.image share.article.image.url(:cover_mobile)
				json.title strip_tags(share.article.title)
				json.publishedAt article_date(share.article)
				json.path article_path(share.article)
				json.set! :author do
					author = share.article.author
				  json.name author.display_name
				  json.path contributor_path(slug: author.slug)
				end
				exchange = share.article.exchanges.first
				json.set! :exchange do
					json.name exchange.name
					json.path exchange_path(slug: exchange.slug)
					json.isSponsored exchange.slug == 'sponsored'
					json.slug exchange.slug
				end
			end
		end
	end

	json.set! :ratingsSummary do
		json.articleCount "#{pluralize(@user.ratingsSummary[:article_count], 'article')} rated"
		json.wellWritten @user.ratingsSummary[:well_written]
		json.validPoints @user.ratingsSummary[:valid_points]
		json.agree @user.ratingsSummary[:agree]
	end

	json.set! :ratings do
		json.array! @user.ratings do |share|
			json.stamp share.created_at.to_i
			json.share share_info_as_json(share, true)
			json.canInteract user_signed_in? && share.current_user_can_interact(current_user)
			json.iAgreeWithPost user_signed_in? ? share.agrees.map(&:user_id).include?(current_user.id) : false
			json.iDisagreeWithPost user_signed_in? ? share.disagrees.map(&:user_id).include?(current_user.id) : false
			json.set! :ratings do
				json.wellWritten share.rating_well_written
				json.validPoints share.rating_valid_points
				json.agree share.rating_agree
			end
			json.set! :user do
				json.displayName displayName
				json.username fullUsername
				json.image profileImage
			end
			json.set! :article do
				json.id share.article.id
				json.snippet article_excerpt_for_listing(share.article, 160)
				json.image share.article.image.url(:cover_mobile)
				json.title strip_tags(share.article.title)
				json.publishedAt article_date(share.article)
				json.path article_path(share.article)
				json.set! :author do
					author = share.article.author
				  json.name author.display_name
				  json.path contributor_path(slug: author.slug)
				end
				exchange = share.article.exchanges.first
				json.set! :exchange do
					json.name exchange.name
					json.path exchange_path(slug: exchange.slug)
					json.isSponsored exchange.slug == 'sponsored'
					json.slug exchange.slug
				end
			end
		end
	end

	json.set! :commentActions do
		json.array! @comment_actions do |comment_feed_item|
			comment = comment_feed_item.actionable
			share = comment.commentable
			json.stamp comment.created_at.to_i
			json.share share_info_as_json(share, true)
			json.canInteract user_signed_in? && share.current_user_can_interact(current_user)
			json.iAgreeWithPost user_signed_in? ? share.agrees.map(&:user_id).include?(current_user.id) : false
			json.iDisagreeWithPost user_signed_in? ? share.disagrees.map(&:user_id).include?(current_user.id) : false
			json.set! :ratings do
				json.wellWritten share.rating_well_written
				json.validPoints share.rating_valid_points
				json.agree share.rating_agree
			end
			json.set! :user do
				json.displayName displayName
				json.username fullUsername
				json.image profileImage
			end
			json.set! :article do
				json.id share.article.id
				json.snippet article_excerpt_for_listing(share.article, 160)
				json.image share.article.image.url(:cover_mobile)
				json.title strip_tags(share.article.title)
				json.publishedAt article_date(share.article)
				json.path article_path(share.article)
				json.set! :author do
					author = share.article.author
				  json.name author.display_name
				  json.path contributor_path(slug: author.slug)
				end
				exchange = share.article.exchanges.first
				json.set! :exchange do
					json.name exchange.name
					json.path exchange_path(slug: exchange.slug)
					json.isSponsored exchange.slug == 'sponsored'
					json.slug exchange.slug
				end
			end
			json.set! :commentAction do
				json.comment comment.body
				json.date comment.created_at.strftime("%e %b")
				json.action (comment.parent_id.nil? ? "Commented on a post by " : "Replied to a comment by ") + comment.user.display_name
				json.set! :user do
					json.displayName comment.user.display_name
					json.username comment.user.username
					json.image comment.user.profile_photo.url(:square)
				end
			end
		end
	end

	json.set! :opinionActions do
		json.array! @opinion_actions do |opinion_feed_item|
			opinion = opinion_feed_item.actionable
			share = opinion.share
			json.stamp opinion.created_at.to_i
			json.share share_info_as_json(share, true)
			json.canInteract user_signed_in? && share.current_user_can_interact(current_user)
			json.iAgreeWithPost user_signed_in? ? share.agrees.map(&:user_id).include?(current_user.id) : false
			json.iDisagreeWithPost user_signed_in? ? share.disagrees.map(&:user_id).include?(current_user.id) : false
			json.set! :ratings do
				json.wellWritten share.rating_well_written
				json.validPoints share.rating_valid_points
				json.agree share.rating_agree
			end
			json.set! :user do
				json.displayName displayName
				json.username fullUsername
				json.image profileImage
			end
			json.set! :article do
				json.id share.article.id
				json.snippet article_excerpt_for_listing(share.article, 160)
				json.image share.article.image.url(:cover_mobile)
				json.title strip_tags(share.article.title)
				json.publishedAt article_date(share.article)
				json.path article_path(share.article)
				json.set! :author do
					author = share.article.author
				  json.name author.display_name
				  json.path contributor_path(slug: author.slug)
				end
				exchange = share.article.exchanges.first
				json.set! :exchange do
					json.name exchange.name
					json.path exchange_path(slug: exchange.slug)
					json.isSponsored exchange.slug == 'sponsored'
					json.slug exchange.slug
				end
			end
			json.set! :opinionAction do
				json.date opinion.created_at.strftime("%e %b")
				json.action "#{opinion.decision.capitalize}d with a post by #{opinion.user.display_name}"
				json.set! :user do
					json.displayName opinion.user.display_name
					json.username opinion.user.username
					json.image opinion.user.profile_photo.url(:square)
				end
			end
		end
	end
end