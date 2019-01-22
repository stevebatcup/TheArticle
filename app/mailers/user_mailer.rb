class UserMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  # default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views

	include Rails.application.routes.url_helpers
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  include ActionView::Helpers::TextHelper
  include MandrillMailer

  default(
    from: Rails.application.credentials.email_from,
    reply_to: Rails.application.credentials.email_reply_to
  )

  def username_updated(user)
    subject = "Your username on TheArticle has been updated"
    merge_vars = {
      FIRST_NAME: user.display_name,
      CURRENT_YEAR: Date.today.strftime("%Y"),
      NEW_USERNAME: user.username
    }
    body = mandrill_template("username-updated", merge_vars)
    send_mail(user.email, "#{user.first_name} #{user.last_name}", subject, body)
  end

  def reset_password_instructions(user, token, opts={})
    subject = I18n.t('devise.mailer.reset_password_instructions.subject')
    merge_vars = {
      FIRST_NAME: user.display_name,
      USER_URL: edit_password_url(user, reset_password_token: token),
      CURRENT_YEAR: Date.today.strftime("%Y")
    }
    body = mandrill_template("password-reset", merge_vars)
    send_mail(user.email, "#{user.first_name} #{user.last_name}", subject, body)
  end

  def confirmation_instructions(user, token, opts={})
    # if user.confirmed?
    #   send_email_change_confirmation(user, token)
    # else
    send_welcome(user, token)
    # end
  end

  def send_welcome(user, token)
    subject = 'Welcome to TheArticle'
    merge_vars = {
      FNAME: user.first_name,
      LNAME: user.last_name,
      CURRENT_YEAR: Date.today.strftime("%Y"),
      USER_URL: confirmation_url(user, confirmation_token: token),
    }
    body = mandrill_template("registration-phase-1-welcome-email", merge_vars)
    send_mail(user.email, "#{user.first_name} #{user.last_name}", subject, body)
  end

  def send_email_change_confirmation(user, token)
    subject = I18n.t('devise.mailer.email_change.subject')
    merge_vars = {
      FIRST_NAME: user.display_name,
      USER_URL: confirmation_url(user, confirmation_token: token),
      CURRENT_YEAR: Date.today.strftime("%Y")
    }
    body = mandrill_template("email-address-change", merge_vars)
    send_mail(user.email, "#{user.first_name} #{user.last_name}", subject, body)
  end
end