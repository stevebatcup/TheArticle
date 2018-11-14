module ApplicationHelper
	def ga_tracking_id
		Rails.application.credentials.ga_tracking_id[Rails.env.to_sym]
	end
end
