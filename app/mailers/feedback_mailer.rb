class FeedbackMailer < ApplicationMailer
	include Rails.application.routes.url_helpers

  def submit(feedback)
		@feedback = feedback
		mail(
			to: 'TheArticle <hello@maawol.com>',
			subject: "Testing feedback from: #{@feedback.name}",
		)
  end
end
