class QuarantinedThirdPartyShare < ApplicationRecord
	belongs_to	:user
	belongs_to	:article, optional: true
	enum	status: [:pending, :approved, :rejected]
end
