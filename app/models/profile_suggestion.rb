class ProfileSuggestion < ApplicationRecord
	belongs_to	:user
	belongs_to	:suggested, class_name: "User"
  enum status: [ :pending, :accepted, :ignored ]

  def self.delete_suggested(user)
  	self.where(suggested_id: user.id).destroy_all
  end
end
