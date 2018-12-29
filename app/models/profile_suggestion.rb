class ProfileSuggestion < ApplicationRecord
	belongs_to	:user
	belongs_to	:suggested, class_name: "User"
  enum status: [ :pending, :accepted, :ignored ]
end
