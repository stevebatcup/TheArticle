class AdminMailer < ApplicationMailer
	include Rails.application.routes.url_helpers
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
end
