class UserMailer < ApplicationMailer
	include Rails.application.routes.url_helpers
	include MandrillMailer

  def send_welcome(email_address, first_name, last_name)
    subject = 'Welcome to TheArticle'
    merge_vars = {
      "FNAME" => first_name,
      "LNAME" => last_name
    }
    body = mandrill_template("registration", merge_vars)
    send_mail(email_address, subject, body)
  end
end
