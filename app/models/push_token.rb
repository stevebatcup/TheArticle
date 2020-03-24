class PushToken < ApplicationRecord
	belongs_to	:user
	validates_uniqueness_of :token
end
