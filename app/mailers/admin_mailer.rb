class AdminMailer < ApplicationMailer
	def concern_report(concern)
		@concern = concern
		mail(
			to: Rails.application.credentials.concern_report_email[:development],
			subject: "New concern report",
		)
	end
end
