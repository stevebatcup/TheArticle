class QuarantinedThirdPartyShare < ApplicationRecord
	belongs_to	:user
	belongs_to	:admin_user, foreign_key: :handled_by_admin_user_id, class_name: 'User'
	belongs_to	:article, optional: true
	enum	status: [:pending, :approved, :rejected]

	def self.pending
		where(status: :pending)
	end

	def self.approved
		where(status: :approved)
	end

end
