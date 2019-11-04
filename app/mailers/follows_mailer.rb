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
    subject = "You have been followed by #{follower.display_name}"
    merge_vars = {
      FIRST_NAME: followed.display_name,
      CURRENT_YEAR: Date.today.strftime("%Y"),
      FOLLOWER_DISPLAY_NAME: follower.display_name,
      FOLLOWER_USERNAME: follower.username,
      FOLLOWER_URL: profile_url(slug: follower.slug),
      MC_PREVIEW_TEXT: "Follow them back to become ‘mutually connected’ and engage with them on the site."
    }
    body = mandrill_template("follow-as-it-happens", merge_vars)
    send_mail(followed.email, "#{followed.first_name} #{followed.last_name}", subject, body, followed.id)
  end

  def daily_and_weekly(followed, followers)
    if followers.length == 1
      subject = "You have been followed by #{followers.first.display_name}"
    else
      other_count = followers.length - 1
      subject = "You have been followed by #{followers.first.display_name} and #{pluralize(other_count, 'other')}"
    end
    merge_vars = {
      FIRST_NAME: followed.display_name,
      CURRENT_YEAR: Date.today.strftime("%Y"),
      FOLLOWER_HTML: build_follower_list_html(followers),
      MC_PREVIEW_TEXT: "Follow them back to become ‘mutually connected’ and engage with them on the site."
    }
    body = mandrill_template("follows-daily-and-weekly", merge_vars)
    send_mail(followed.email, "#{followed.first_name} #{followed.last_name}", subject, body, followed.id)
  end

  def build_follower_list_html(followers)
    html = "<ul style='padding:0; margin:0;'>"
    followers.each do |follower|
      path = profile_url(slug: follower.slug)
      html << "<li style='list-style:none; line-height: 2.2'><a href='#{path}'>#{follower.display_name}</a> (<a href='#{path}'>#{follower.username}</a>)</li>"
    end
    html << "</ul>"
    html
  end
end
