class DeveloperMailer < ApplicationMailer
	include Rails.application.routes.url_helpers
	include MandrillMailer

	default(
	  from: Rails.application.credentials.email_from,
	  reply_to: Rails.application.credentials.email_reply_to
	)

	def developer_email
		Rails.application.credentials.developer[:email]
	end

	def developer_name
		Rails.application.credentials.developer[:name]
	end

	def blacklist_updated(user, admin_user)
		@user = user
		@admin_user = admin_user
		mail(
			to: developer_email,
			subject: "User added to blacklist",
		)
	end

	def rss_feed_invalid(url)
		subject = "WARNING: RSS Feed invalid"
		merge_vars = {
		  FEED_URL: url,
		  FNAME: developer_name,
		  BODY: "<p>The RSS feed is broken, fix it now dude!<br /><a href='#{url}'>#{url}</a></p>"
		}
		body = mandrill_template("developer-tools", merge_vars)
		send_mail(developer_email, developer_name, subject, body)
	end

end
