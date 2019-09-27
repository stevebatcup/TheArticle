class BlackListUser < ApplicationRecord
	belongs_to	:user
	belongs_to	:admin_user, class_name: 'User', foreign_key: :added_by_admin_user_id
	# after_create	:email_developer

	def admin_user_name
		self.admin_user.display_name
	end

	def email_developer
		DeveloperMailer.blacklist_updated(self.user, self.admin_user).deliver_now
	end
end
