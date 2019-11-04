class Mute < ApplicationRecord
	belongs_to	:user
	belongs_to	:muted, class_name: 'User'

	def self.active
		where(status: :active)
	end
end
