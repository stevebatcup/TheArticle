class PushToken < ApplicationRecord
	belongs_to	:user
	validates_uniqueness_of :token
	after_create	:switch_account_settings_on

	def switch_account_settings_on
		user.allow_all_pushes
	end
end
