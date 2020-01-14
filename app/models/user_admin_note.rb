class UserAdminNote < ApplicationRecord
	belongs_to	:user

	def admin
		User.find_by(id: self.admin_user_id)
	end
end
