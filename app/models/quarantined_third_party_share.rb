class QuarantinedThirdPartyShare < ApplicationRecord
	belongs_to	:user
	belongs_to	:article
	enum	status: [:pending, :approved, :rejected]
end
