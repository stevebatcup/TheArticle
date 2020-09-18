namespace :notifications do
	task :daily_follows => :environment do
		items = DailyUserMailItem.select(:id, :user_id).where(action_type: "follow").where("created_at > DATE_SUB(CONCAT(CURDATE(), ' ', '17:00:00'), INTERVAL 1 DAY)").group(:user_id)
		items.each do |item|
			if user = User.active.find_by(id: item.user_id)
				user.send_daily_follows_mail
			else
				DailyUserMailItem.where(user_id: item.user_id).destroy_all
			end
		end
	end

	task :weekly_follows => :environment do
		items = WeeklyUserMailItem.select(:id, :user_id).where(action_type: "follow").where("created_at >= DATE_SUB(CURDATE(), INTERVAL 1 WEEK)").group(:user_id)
		items.each do |item|
			if user = User.active.find_by(id: item.user_id)
				user.send_weekly_follows_mail
			else
				WeeklyUserMailItem.where(user_id: item.user_id).destroy_all
			end
		end
	end

	task :daily_categorisations => :environment do
		DailyUserMailItem.select(:id, :user_id)
											.where(action_type: "categorisation")
											.where("created_at > DATE_SUB(CONCAT(CURDATE(), ' ', '17:00:00'), INTERVAL 1 DAY)")
											.group(:user_id)
											.find_in_batches(batch_size: 200) do |group|
			sleep(2)
			group.each do |item|
				sleep(0.2)
				if user = User.where(status: :active).find_by(id: item.user_id)
					user.send_daily_categorisations_mail
				else
					DailyUserMailItem.where(user_id: item.user_id).destroy_all
				end
			end
		end
	end

	task :check_daily_sends => :environment do
		items = DailyUserMailItem.select(:id, :user_id).where(action_type: "categorisation").where("created_at > DATE_SUB(CONCAT(CURDATE(), ' ', '17:00:00'), INTERVAL 1 DAY)").group(:user_id)
		if items.length > 500
			e = Exception.new("#{items.length} categorisation mails left in the 'daily user mail items' table");
			DeveloperMailer.categorisation_mailout_exception(e).deliver_now
		end
	end

	task :weekly_categorisations => :environment do
		items = WeeklyUserMailItem.select(:id, :user_id).where(action_type: "categorisation").where("created_at >= DATE_SUB(CURDATE(), INTERVAL 1 WEEK)").group(:user_id)
		items.each do |item|
			if user = User.where(status: :active).find_by(id: item.user_id)
				user.send_weekly_categorisations_mail
			else
				WeeklyUserMailItem.where(user_id: item.user_id).destroy_all
			end
		end
	end
end