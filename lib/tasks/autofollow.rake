namespace :autofollow do
	task :jay => :environment do
		jay = User.find(124)

		unfollowed = User.active.where("DATE(created_at) <= DATE_SUB(CURDATE(), INTERVAL 1 DAY)").where.not(id: jay.followings.map(&:followed_id)).limit(500)
		if unfollowed.any?
			unfollowed.each do |user|
				jay.followings << Follow.new({followed_id: user.id})
			end
			jay.save

			unfollowed.each do |user|
				sleep(1)
				user.send_followed_mail_if_opted_in(jay)
			end
		end
	end

	task :lynne => :environment do
		lynne = User.find(254)

		unfollowed = User.active.where("DATE(created_at) <= DATE_SUB(CURDATE(), INTERVAL 2 DAY)").where.not(id: lynne.followings.map(&:followed_id)).limit(500)
		if unfollowed.any?
			unfollowed.each do |user|
				lynne.followings << Follow.new({followed_id: user.id})
			end
			lynne.save

			unfollowed.each do |user|
				sleep(1)
				user.send_followed_mail_if_opted_in(lynne)
			end
		end
	end

	task :daniel => :environment do
		if Rails.env.development?
			daniel = User.find(23)
		else
			daniel = User.find(68)
		end

		unfollowed = User.active.where("DATE(created_at) <= DATE_SUB(CURDATE(), INTERVAL 3 DAY)").where.not(id: daniel.followings.map(&:followed_id)).limit(500)
		if unfollowed.any?
			unfollowed.each do |user|
				daniel.followings << Follow.new({followed_id: user.id})
			end
			daniel.save

			unfollowed.each do |user|
				sleep(1)
				user.send_followed_mail_if_opted_in(daniel)
			end
		end
	end

	task :charlotte => :environment do
		charlotte = User.find(125)

		unfollowed = User.active.where("DATE(created_at) <= DATE_SUB(CURDATE(), INTERVAL 4 DAY)").where.not(id: charlotte.followings.map(&:followed_id)).limit(500)
		if unfollowed.any?
			unfollowed.each do |user|
				charlotte.followings << Follow.new({followed_id: user.id})
			end
			charlotte.save

			unfollowed.each do |user|
				sleep(1)
				user.send_followed_mail_if_opted_in(charlotte)
			end
		end
	end
end