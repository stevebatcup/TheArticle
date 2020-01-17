class ProfileSuggestionArchive < ApplicationRecord
	belongs_to	:user
	enum reason_for_archive: [:followed, :ignored, :expired]

	def self.delete_suggested(user)
		self.where(suggested_id: user.id).destroy_all
	end
end
