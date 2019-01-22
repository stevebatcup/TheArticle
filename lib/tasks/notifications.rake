namespace :notifications do
	task :group_follows => :environment do
		User.active.each do |user|
			user.generate_follow_groups(6)
		end
	end

	task :group_agrees => :environment do
		User.active.each do |user|
			user.generate_opinion_groups(:agree, 1)
		end
	end

	task :group_disagrees => :environment do
		User.active.each do |user|
			user.generate_opinion_groups(:disagree, 1)
		end
	end
end