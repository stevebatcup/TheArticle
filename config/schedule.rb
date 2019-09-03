# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every :reboot do
	command "cd #{Dir.pwd} && RAILS_ENV=#{@environment} /home/ubuntu/.rbenv/bin/rbenv exec bundle exec rake ts:restart >> /var/www/thearticle/rails/shared/log/thinking_sphinx.log 2>&1"
end

every	5.minutes do
	command "cd #{Dir.pwd} && RAILS_ENV=#{@environment} bundle exec rake ts:index >> /var/www/thearticle/rails/shared/log/thinking_sphinx.log 2>&1"
end

every	2.minutes do
	rake "articles:fetch_scheduled_posts >> /var/www/thearticle/rails/shared/log/scheduled_articles.log 2>&1"
end

every	1.day, at: '8:00 pm' do
	rake "notifications:daily_follows >> /var/www/thearticle/rails/shared/log/notification_emails.log 2>&1"
end

every	:wednesday, at: '8:00 pm' do
	rake "notifications:weekly_follows >> /var/www/thearticle/rails/shared/log/notification_emails.log 2>&1"
end

every	1.day, at: '5:00 pm' do
	rake "notifications:daily_categorisations >> /var/www/thearticle/rails/shared/log/notification_emails.log 2>&1"
end
every	1.day, at: '11:45 pm' do
	rake "notifications:daily_categorisations >> /var/www/thearticle/rails/shared/log/notification_emails.log 2>&1"
end

every	:monday, at: '7:00 am' do
	rake "notifications:weekly_categorisations >> /var/www/thearticle/rails/shared/log/notification_emails.log 2>&1"
end

every	1.day, at: '6:00 pm' do
	rake "profiles:second_wizard_nudge >> /var/www/thearticle/rails/shared/log/notification_emails.log 2>&1"
end
