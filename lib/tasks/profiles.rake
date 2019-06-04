namespace :profiles do
	task :second_wizard_nudge => :environment do
		yesterday = Date.yesterday
		yesterdays_registrations = User.where(status: :active)
																	.where(has_completed_wizard: false)
																	.where(created_at: yesterday.midnight..yesterday.end_of_day)
		yesterdays_registrations.each do |user|
			UserMailer.send_second_wizard_nudge(user).deliver_now
		end
	end
end