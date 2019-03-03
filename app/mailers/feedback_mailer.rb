class FeedbackMailer < ApplicationMailer
	include Rails.application.routes.url_helpers
	include MandrillMailer

  def submit(feedback)
		@feedback = feedback
		send_mail('info@thearticle.com',
							'TheArticle',
							"Testing feedback from: #{@feedback.name}",
							render_to_string(:action => "submit", :layout => false))
  end
end
