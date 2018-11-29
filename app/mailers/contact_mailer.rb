class ContactMailer < ApplicationMailer
	include Rails.application.routes.url_helpers
  def contact(contact_data)
		@contact = contact_data
		mail(
			to: 'TheArticle <info@thearticle.com>',
			subject: "New contact form: #{@contact[:subject]}",
		)
  end
end
