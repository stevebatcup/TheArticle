class ApprovedThirdPartyShare < QuarantinedThirdPartyShare
	default_scope	-> { where(status: :approved) }

	def admin_user_name
		self.admin_user.display_name
	end
end