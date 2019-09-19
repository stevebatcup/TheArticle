json.id @user.id

if @full_details
	json.fullDetailsLoaded true
	json.fullName @user.full_name
	json.lastIpAddress @user.last_sign_in_ip
	json.profileUrl "#{profile_url(slug: @user.slug)}?from_admin=1"
	json.lastSignIn @user.last_sign_in_at.present? ? @user.last_sign_in_at.strftime("%b %e, %Y at %H:%m") : nil
	json.verified @user.has_completed_wizard? ? "Yes" : "No"
	json.blacklisted @user.is_blacklisted?
	json.watchlisted @user.is_watchlisted?
	json.blacklistedHuman @user.is_blacklisted? ? "Yes" : "No"
	json.watchlistedHuman @user.is_watchlisted? ? "Yes" : "No"
	json.isContributor @user.is_author? ? "Yes" : "No"
	json.signupIpAddress @user.signup_ip_address
	json.signupLocation "#{@user.signup_ip_city}, #{@user.signup_ip_region}, #{@user.signup_ip_country}"
	json.profilePhoto @user.profile_photo.url(:square)
	json.coverPhoto @user.cover_photo.url(:desktop)
	json.authorId @user.author_id.to_i if @user.author_id.present?
	json.genuineVerified @user.verified_as_genuine
	json.notificationSettings do
		json.followers @user.notification_settings.find_by(key: :email_followers).humanise_value
		json.categorisations @user.notification_settings.find_by(key: :email_exchanges).humanise_value
		json.weeklyNewsletter @user.opted_into_weekly_newsletters? ? "Yes" : "No"
		json.offers @user.opted_into_offers? ? "Yes" : "No"
	end
	json.set! :muting do
		json.array! @user.mutes.active.map(&:muted) do |user|
			json.id user.id
			json.name user.full_name
		end
	end
	json.set! :mutedBy do
		json.array! @user.muted_bys.active.map(&:user) do |user|
			json.id user.id
			json.name user.full_name
		end
	end
	json.set! :blocking do
		json.array! @user.blocks.active.map(&:blocked) do |user|
			json.id user.id
			json.name user.full_name
		end
	end
	json.set! :blockedBy do
		json.array! @user.blocked_bys.active.map(&:user) do |user|
			json.id user.id
			json.name user.full_name
		end
	end

	json.set! :concernsReported do
		json.array! @user.concerns_reported.each do |report|
			json.id report.id
			json.sentAt report.created_at.strftime("%b %e, %Y")
			json.type report.sourceable_type
			json.reason report.primary_reason
			json.path report.admin_path
			json.reporter do
				json.id report.reporter.id
				json.name report.reporter.full_name
			end
		end
	end
	json.set! :concernReports do
		json.array! @user.all_concern_reports.each do |report|
			json.id report.id
			json.sentAt report.created_at.strftime("%b %e, %Y")
			json.type report.sourceable_type
			json.reason report.primary_reason
			json.path report.admin_path
			json.reported do
				json.id report.reported.id
				json.name report.reported.full_name
			end
		end
	end

	json.set! :comments do
		json.array! @user.comments.order(id: :desc).each do |comment|
			json.path "/admin/comments/#{comment.id}"
			json.precis sanitize(truncate(comment.body.html_safe, length: 120, escape: false, separator: /\s/, omission: ' ...'))
			json.sentAt comment.created_at.strftime("%Y-%m-%d %H:%M")
			if comment.commentable
				json.share do
					json.path "/admin/shares/#{comment.commentable.id}"
					if comment.commentable.article
						json.article do
							article = comment.commentable.article
							json.title sanitize(truncate(article.title.html_safe, length: 120, escape: false, separator: /\s/, omission: ' ...'))
							json.path article.remote_article_url.present? ? article.remote_article_url : "/#{article.slug}"
						end
					end
				end
			end
		end
	end

	json.set! :addingAdditionalEmail do
		json.text ''
		json.status ''
		json.css ''
	end
	json.set! :additionalEmails do
		json.array! @user.additional_emails.order(text: :asc).each do |email|
			json.id email.id
			json.text email.text
		end
	end

else
	json.fullDetailsLoaded = false
	json.firstName @user.first_name
	json.lastName @user.last_name
	json.name @user.full_name.html_safe
	json.displayName @user.display_name.html_safe
	json.username @user.username
	json.email @user.email
	json.slug @user.slug
	json.signedUp @user.human_created_at
	json.accountStatus @user.admin_account_status.capitalize
	json.profileStatus @user.admin_profile_status.capitalize
end