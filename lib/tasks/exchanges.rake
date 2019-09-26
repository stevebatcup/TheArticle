require 'uri'
namespace :exchanges do
	task :update_follower_counts => :environment do
		Exchange.all.each do |exchange|
			follower_count = exchange.users.length
			Exchange.record_timestamps = false
			exchange.update_attribute(:follower_count, follower_count)
		end
	end
end
