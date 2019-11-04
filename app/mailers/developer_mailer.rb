class DeveloperMailer < ApplicationMailer
	def blacklist_updated(user, admin_user)
		@user = user
		@admin_user = admin_user
		mail(
			to: "steve@maawol.com",
			subject: "User added to blacklist",
		)
	end
end
