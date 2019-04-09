namespace :notifications do
	task :daily_follows => :environment do
		items = DailyUserMailItem.select(:user_id).where(action_type: "follow").where("DATE(created_at) = CURDATE()").group(:user_id)
		items.each do |item|
			if user = User.active.find_by(id: item.user_id)
				user.send_daily_follows_mail
			end
		end
	end

	task :weekly_follows => :environment do
		items = WeeklyUserMailItem.select(:user_id).where(action_type: "follow").where("created_at >= DATE_SUB(CURDATE(), INTERVAL 1 WEEK)").group(:user_id)
		items.each do |item|
			if user = User.active.find_by(id: item.user_id)
				user.send_weekly_follows_mail
			end
		end
	end

	task :daily_categorisations => :environment do
		items = DailyUserMailItem.select(:user_id).where(action_type: "categorisation").where("DATE(created_at) = CURDATE()").group(:user_id)
		items.each do |item|
			if user = User.active.find_by(id: item.user_id)
				user.send_daily_categorisations_mail
			end
		end
	end

	task :weekly_categorisations => :environment do
		items = WeeklyUserMailItem.select(:user_id).where(action_type: "categorisation").where("created_at >= DATE_SUB(CURDATE(), INTERVAL 1 WEEK)").group(:user_id)
		items.each do |item|
			if user = User.active.find_by(id: item.user_id)
				user.send_weekly_categorisations_mail
			end
		end
	end
end