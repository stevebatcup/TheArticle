class ContactMailer < ApplicationMailer
	include Rails.application.routes.url_helpers
	include MandrillMailer

  def contact(contact_data)
		@contact = contact_data
		send_mail('info@thearticle.com',
							'TheArticle',
							"New contact form: #{@contact[:subject]}",
							render_to_string(:action => "contact", :layout => false))
  end
end
