class WatchListUser < ApplicationRecord
	belongs_to	:user
	belongs_to	:admin_user, class_name: 'User', foreign_key: :added_by_admin_user_id

	def admin_user_name
		self.admin_user.display_name
	end
end
