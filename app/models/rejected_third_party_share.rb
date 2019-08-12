class RejectedThirdPartyShare < QuarantinedThirdPartyShare
	default_scope	-> { where(status: :rejected) }

	def admin_user_name
		self.admin_user.display_name
	end
end