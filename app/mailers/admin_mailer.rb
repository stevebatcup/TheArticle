class AdminMailer < ApplicationMailer
	include Rails.application.routes.url_helpers
  include ActionView::Helpers::TextHelper
	include MandrillMailer

	def concern_report_receiver
		Rails.application.credentials.concern_report_email[Rails.env.to_sym]
	end

	def concern_report(concern)
		subject = "New concern report"
		merge_vars = {
		  REPORTER_NAME: concern.reporter.display_name,
		  REPORTER_EMAIL: concern.reporter.email,
		  REPORTER_ID: concern.reporter.id,
		  REPORTED_NAME: concern.reported.display_name,
		  REPORTED_EMAIL: concern.reported.email,
		  REPORTED_ID: concern.reported.id,
		  REASON: concern.build_reason_sentence,
		  SENT_VIA_TYPE: concern.sourceable_type_for_email,
		  SENT_VIA_ID: concern.sourceable_id,
		  MORE_INFO: (concern.more_info && concern.more_info.length ? concern.more_info : 'None')
		}
		body = mandrill_template("concern-report", merge_vars)
		send_mail(concern_report_receiver, "Administrator", subject, body)
	end

	def bio_updated(user)
		subject = "Your bio on TheArticle has been updated"
		message = "Your bio on TheArticle has been updated and now reads: \n\n <em>&ldquo;#{user.bio}&rdquo;</em>\n"
		merge_vars = {
			FNAME: user.first_name,
		  BODY: simple_format(message.html_safe)
		}
		body = mandrill_template("admin-account", merge_vars)
		send_mail(user.email, user.full_name, subject, body)
	end

	def new_message(user, subject, message)
		merge_vars = {
			FNAME: user.first_name,
		  BODY: simple_format(message)
		}
		body = mandrill_template("admin-account", merge_vars)
		send_mail(user.email, user.full_name, subject, body)
	end
end
