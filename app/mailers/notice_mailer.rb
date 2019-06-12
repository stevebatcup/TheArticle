class NoticeMailer < Devise::Mailer
  helper :application
	include Rails.application.routes.url_helpers
  include Devise::Controllers::UrlHelpers
  include ActionView::Helpers::TextHelper
  include MandrillMailer

	def reject_third_party_share(share)
		user = share.user
		subject = "Your post on TheArticle has been rejected"
		merge_vars = {
		  FIRST_NAME: user.display_name,
		  CURRENT_YEAR: Date.today.strftime("%Y"),
		  SHARE_URL: share.url
		}
		body = mandrill_template("third-party-post-rejected", merge_vars)
		send_mail(user.email, "#{user.first_name} #{user.last_name}", subject, body, user.id)
	end

	def approve_third_party_share(share)
		user = share.user
		subject = "Your post on TheArticle has been approved"
		merge_vars = {
		  FIRST_NAME: user.display_name,
		  CURRENT_YEAR: Date.today.strftime("%Y"),
		  SHARE_URL: share.url
		}
		body = mandrill_template("third-party-post-approved", merge_vars)
		send_mail(user.email, "#{user.first_name} #{user.last_name}", subject, body, user.id)
	end
end