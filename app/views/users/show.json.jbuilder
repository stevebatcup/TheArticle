json.set! :profile do
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
		json.sentence recentFollowingSummary[:sentence].html_safe
		json.user do
			json.image profileImage
			json.displayName displayName
			json.username fullUsername
		end
	end

	recentFollowedSummary  = following_summary(@user.recent_followeds(48), "followed")
	json.recentFollowedSummary do
		json.stamp recentFollowedSummary[:stamp]
		json.date recentFollowedSummary[:date]
		json.sentence recentFollowedSummary[:sentence].html_safe
		json.user do
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
			json.displayName follower.display_name
			json.username follower.username
			json.bio bio_excerpt(follower, browser.device.mobile? ? 9 : 28)
			json.profilePhoto follower.profile_photo.url(:square)
			json.coverPhoto follower.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
			json.imFollowing user_signed_in? ? follower.is_followed_by(current_user) : false
			json.isFollowingMe user_signed_in? ? current_user.is_followed_by(@user) : false
		end
	end

	json.set! :followings do
		json.array! @user.followings do |following|
			json.id following.followed_id
			json.displayName following.followed.display_name
			json.username following.followed.username
			json.bio bio_excerpt(following.followed, browser.device.mobile? ? 9 : 28)
			json.profilePhoto following.followed.profile_photo.url(:square)
			json.coverPhoto following.followed.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
			json.imFollowing user_signed_in? ? following.followed.is_followed_by(current_user) : false
			json.isFollowingMe user_signed_in? ? current_user.is_followed_by(@user) : false
		end
	end

	json.set! :shares do
		json.array! @user.share_onlys do |share|
			json.stamp share.created_at.to_i
			json.set! :share do
				json.date share.created_at.strftime("%e %b")
				json.commentCount pluralize(share.commentCount, 'comment')
				json.agreeCount "#{pluralize(share.agreeCount, 'person')} agree"
				json.disagreeCount "#{pluralize(share.disagreeCount, 'person')} disagree"
				json.comments share.comments
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

	json.set! :ratingsSummary do
		json.articleCount "#{pluralize(@user.ratingsSummary[:article_count], 'article')} rated"
		json.wellWritten @user.ratingsSummary[:well_written]
		json.validPoints @user.ratingsSummary[:valid_points]
		json.agree @user.ratingsSummary[:agree]
	end

	json.set! :ratings do
		json.array! @user.ratings do |share|
			json.stamp share.created_at.to_i
			json.set! :share do
				json.isRatings true
				json.date share.created_at.strftime("%e %b")
				json.commentCount pluralize(share.commentCount, 'comment')
				json.agreeCount "#{pluralize(share.agreeCount, 'person')} agree"
				json.disagreeCount "#{pluralize(share.disagreeCount, 'person')} disagree"
				json.comments share.comments
			end
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
end