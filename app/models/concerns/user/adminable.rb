module User::Adminable
  def self.included(base)
    base.extend ClassMethods
  end

	def is_admin?
	  [:nothing].exclude?(self.admin_level.to_sym)
	end

	def has_reached_rejected_post_limit?
	  self.quarantined_third_party_shares.where(status: :rejected).size > 5
	end

	def human_created_at
		self.created_at.strftime("dsfsdf")
	end

	def is_blacklisted?
		self.black_list_user.present?
	end

	def add_to_blacklist(reason)
		self.build_black_list_user({reason: reason})
		self.save
	end

	# def status_for_admin
	#   self.confirmed? ? "Verified" : "Unverified"
	# end

	module ClassMethods
	end
end