class NotificationSetting < ApplicationRecord
	belongs_to	:user

	def humanise_value
		self.value.humanize.capitalize
	end
end
