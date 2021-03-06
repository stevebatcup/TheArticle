# Learn more: http://github.com/javan/whenever
every	2.minutes, roles: [:web1] do
	rake "articles:fetch_scheduled_posts >> /var/www/thearticle/rails/shared/log/scheduled_articles.log 2>&1"
end

every	1.day, at: '8:00 pm', roles: [:web2] do
	rake "notifications:daily_follows >> /var/www/thearticle/rails/shared/log/notification_emails.log 2>&1"
end

every	:wednesday, at: '8:00 pm', roles: [:web2] do
	rake "notifications:weekly_follows >> /var/www/thearticle/rails/shared/log/notification_emails.log 2>&1"
end

every	1.day, at: '5:00 pm', roles: [:web1] do
	rake "notifications:daily_categorisations >> /var/www/thearticle/rails/shared/log/notification_emails.log 2>&1"
end
# every	1.day, at: '9:30 pm', roles: [:web2] do
# 	rake "notifications:daily_categorisations >> /var/www/thearticle/rails/shared/log/notification_emails.log 2>&1"
# end
every	1.day, at: '11:00 pm', roles: [:web1] do
	rake "notifications:daily_categorisations >> /var/www/thearticle/rails/shared/log/notification_emails.log 2>&1"
end
every	1.day, at: '11:20 pm', roles: [:web2] do
	rake "notifications:check_daily_sends >> /var/www/thearticle/rails/shared/log/notification_emails.log 2>&1"
end

every	:monday, at: '7:00 am', roles: [:web2] do
	rake "notifications:weekly_categorisations >> /var/www/thearticle/rails/shared/log/notification_emails.log 2>&1"
end

every	1.day, at: '6:00 pm', roles: [:web2] do
	rake "profiles:second_wizard_nudge >> /var/www/thearticle/rails/shared/log/notification_emails.log 2>&1"
end

every	1.day, at: '8:30 pm', roles: [:web1] do
	rake "autofollow:daniel"
end
every	1.day, at: '9:30 pm', roles: [:web2] do
	rake "autofollow:jay"
end

every	2.hours, roles: [:web2] do
	rake "suggestions:dedupe"
end
every	1.day, at: '1:30 am', roles: [:web1] do
	rake "suggestions:archive_expired"
end

every	15.minutes, roles: [:web1] do
	rake "exchanges:update_follower_counts"
end

every 1.hour, roles: [:web1] do
	rake "articles:fetch_bibblio_meta >> /var/www/thearticle/rails/shared/log/bibblio.log 2>&1"
end

every 20.minutes, roles: [:web1] do
	rake "feeds:clean >> /var/www/thearticle/rails/shared/log/feeds.log 2>&1"
end

every	6.hours, roles: [:web2] do
	rake "articles:validate_rss_feed"
end