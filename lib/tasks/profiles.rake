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

	task :add_to_bibblio => :environment do
		users = User.active.where(on_bibblio: false).where("created_at < DATE_SUB(CURDATE(), INTERVAL 4 WEEK)").limit(250)
		if users.any?
			users.each do |user|
				puts "adding #{user.id} to bibblio\n"
				user.add_to_bibblio
				sleep(1)
			end
		end
	end
end