namespace :autofollow do
	task :olivia => :environment do
		if Rails.env.development?
			olivia = User.find(27)
		else
			olivia = User.find(70)
		end

		unfollowed = User.active.where("DATE(created_at) <= DATE_SUB(CURDATE(), INTERVAL 1 DAY)").where.not(id: olivia.followings.map(&:followed_id))
		if unfollowed.any?
			unfollowed.each do |user|
				olivia.followings << Follow.new({followed_id: user.id})
			end
			olivia.save

			unfollowed.each do |user|
				user.send_followed_mail_if_opted_in(olivia)
			end
		end
	end

	task :daniel => :environment do
		if Rails.env.development?
			daniel = User.find(23)
		else
			daniel = User.find(68)
		end

		unfollowed = User.active.where("DATE(created_at) <= DATE_SUB(CURDATE(), INTERVAL 3 DAY)").where.not(id: daniel.followings.map(&:followed_id))
		if unfollowed.any?
			unfollowed.each do |user|
				daniel.followings << Follow.new({followed_id: user.id})
			end
			daniel.save

			unfollowed.each do |user|
				user.send_followed_mail_if_opted_in(daniel)
			end
		end
	end
end
