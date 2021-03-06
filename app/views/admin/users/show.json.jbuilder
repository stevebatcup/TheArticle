json.id @user.id

if @full_details
	json.fullDetailsLoaded true
	json.fullName @user.full_name
	json.bio @user.bio
	json.bioUpdated false
	json.bioUpdating false
	json.alertBioUpdated false
	json.lastIpAddress @user.last_sign_in_ip
	json.profileUrl "#{profile_url(slug: @user.slug)}?from_admin=1"
	json.lastSignIn @user.last_sign_in_at.present? ? @user.last_sign_in_at.strftime("%b %e, %Y at %H:%m") : nil
	json.registrationSource @user.registration_source
	json.verified @user.has_completed_wizard? ? "Yes" : "No"
	json.deleted @user.status.to_sym == :deleted
	json.blacklisted @user.is_blacklisted?
	json.watchlisted @user.is_watchlisted?
	json.blacklistedHuman @user.is_blacklisted? ? "Yes" : "No"
	json.watchlistedHuman @user.is_watchlisted? ? "Yes" : "No"
	json.isContributor @user.is_author? ? "Yes" : "No"
	json.signupIpAddress @user.signup_ip_address
	json.signupLocation "#{@user.signup_ip_city}, #{@user.signup_ip_region}, #{@user.signup_ip_country}"

	json.photoCrop do
		json.cropper nil
		json.scaleX 1
		json.scaleY 1
	end

	json.newAdminNote do
		json.note ''
		json.adding false
		json.added false
		json.error false
	end
	json.set! :adminNotes do
		json.array! @user.user_admin_notes.order(created_at: :desc) do |note|
			json.id note.id
			json.note note.note
			json.administrator note.admin.full_name
			json.addedAt note.created_at.strftime("%b %e, %Y at %H:%m")
		end
	end

	json.profilePhoto do
		json.src ''
		json.originalSrc @user.profile_photo.url
		json.isDefault @user.has_default_profile_photo
		json.removing false
		json.uploading false
		json.error nil
		json.width 300
		json.height 300
	end

	json.coverPhoto do
		json.src ''
		json.originalSrc @user.cover_photo.url(:desktop)
		json.removing false
		json.uploading false
		json.error nil
		json.width 570
		json.height 114
	end

	json.authorId @user.author_id.to_i if @user.author_id.present?
	json.genuineVerified @user.verified_as_genuine
	json.newEmail do
		json.subject ''
		json.message ''
		json.error false
		json.sending false
		json.sent false
	end

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

	json.set! :posts do
		json.array! @user.posts.order(id: :desc).each do |post|
			json.id post.id
			json.path "/admin/shares/#{post.id}"
			json.article do
				json.title sanitize(truncate(post.article.title.html_safe, length: 120, escape: false, separator: /\s/, omission: ' ...'))
				json.path post.article.remote_article_url.present? ? post.article.remote_article_url : "/#{post.article.slug}"
			end
			json.precis sanitize(truncate(post.post.html_safe, length: 120, escape: false, separator: /\s/, omission: ' ...'))
			json.createdAt post.created_at.strftime("%Y-%m-%d %H:%M")
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

	json.set! :addingLinkedAccount do
		json.id ''
		json.status ''
		json.css ''
	end
	json.set! :linkedAccounts do
		json.array! @user.linked_accounts.order(linked_account_id: :desc).each do |linked_account|
			json.id linked_account.linked_account_id
			json.displayName linked_account.linked_account.display_name
		end
	end

	donations = []
	Donation.non_recurrring_donations_for_user(@user).each do |donation|
		donations << {
			id: donation.id,
			amount: number_to_currency(donation.amount, unit: '£'),
			donatedOn: donation.created_at.strftime("%d %B, %Y"),
			recurring: false,
			status: donation.status
		}
	end

	recurring = Donation.recurrring_donation_for_user(@user)
	if recurring
		donations << {
			id: recurring.id,
			amount: number_to_currency(recurring.amount, unit: '£'),
			donatedOn: recurring.created_at.strftime("%d %B, %Y"),
			recurring: true,
			status: recurring.status
		}
	end

	json.donations donations

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