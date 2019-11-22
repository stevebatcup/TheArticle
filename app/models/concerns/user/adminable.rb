module User::Adminable
  def self.included(base)
    base.extend ClassMethods
  end

  def is_admin?
    [:admin, :super_admin].include?(self.admin_level.to_sym)
  end

  def is_super_admin?
    self.admin_level.to_sym == :super_admin
  end

	def has_reached_rejected_post_limit?
	  self.quarantined_third_party_shares.where(status: :rejected).size > 5
	end

	def human_created_at
		self.created_at.strftime("%b %e, %Y")
	end

	def is_blacklisted?
		self.black_list_user.present?
	end

	def is_watchlisted?
		self.watch_list_user.present?
	end

	def add_to_blacklist(reason, admin_user, email)
		self.build_black_list_user({reason: reason, added_by_admin_user_id: admin_user.id, email: email})
		self.save
	end

	def add_to_watchlist(reason, admin_user)
		self.build_watch_list_user({reason: reason, added_by_admin_user_id: admin_user.id})
		self.save
	end

	def get_reported_count
		ConcernReport.unscoped.where(reported_id: self.id).size
	end

	def admin_account_status
		[:active, :deactivated].include?(self.status.to_sym) ? 'active' : 'deleted'
	end

	def admin_profile_status
		if status.to_sym == :deleted
			'deleted'
		else
			if has_completed_wizard
				profile_is_deactivated? ? 'deactivated' : 'live'
			else
				'incomplete'
			end
		end
	end

	module ClassMethods
	end
end