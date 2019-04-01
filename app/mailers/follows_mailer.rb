class FollowsMailer < Devise::Mailer
  helper :application
	include Rails.application.routes.url_helpers
  include Devise::Controllers::UrlHelpers
  include ActionView::Helpers::TextHelper
  include MandrillMailer

  default(
    from: Rails.application.credentials.email_from,
    reply_to: Rails.application.credentials.email_reply_to
  )

  def as_it_happens(followed, follower)
    subject = "TheArticle – you have been followed by #{follower.display_name}"
    merge_vars = {
      FIRST_NAME: followed.display_name,
      CURRENT_YEAR: Date.today.strftime("%Y"),
      FOLLOWER_DISPLAY_NAME: follower.display_name,
      FOLLOWER_USERNAME: follower.username,
      FOLLOWER_URL: profile_url(slug: follower.slug)
    }
    body = mandrill_template("follow-as-it-happens", merge_vars)
    send_mail(followed.email, "#{followed.first_name} #{followed.last_name}", subject, body)
  end
end
