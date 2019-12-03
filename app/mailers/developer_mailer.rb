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
		subject = "User added to blacklist"
		merge_vars = {
		  FNAME: developer_name,
		  BODY: "<p>A user has been added to the blacklist by <b>#{ admin_user.full_name }</b></p>
							<table cellpadding='8' cellspacing='0' border='1'>
								<thead>
									<tr>
										<th><b>Name</b></th>
										<th><b>Email</b></th>
										<th><b>User ID</b></th>
									</tr>
								</thead>
								<tbody>
									<tr>
										<td>#{ user.full_name }</td>
										<td>#{ user.email }</td>
										<td>#{ user.id }</td>
									</tr>
								</tbody>
							</table>
							<p>Go sort the firewall.....</p>"
		}
		body = mandrill_template("developer-tools", merge_vars)
		send_mail(developer_email, developer_name, subject, body)
	end

	def rss_feed_invalid(url, error_msg)
		subject = "WARNING: RSS Feed invalid"
		merge_vars = {
		  FNAME: developer_name,
		  BODY: "<p>The RSS feed is broken, fix it now dude!<br /><a href='#{url}'>#{url}</a></p>
		  				<p>Error message: #{error_msg}</p>"
		}
		body = mandrill_template("developer-tools", merge_vars)
		send_mail(developer_email, developer_name, subject, body)
	end

end
