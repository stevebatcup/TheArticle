class Share < ApplicationRecord
	acts_as_commentable
	validates_presence_of	:article_id, :user_id
	belongs_to	:user
	belongs_to	:article


	def self.share_onlys
		where(rating_well_written: 0, rating_valid_points: 0, rating_agree: 0)
	end

	def self.ratings
		where('rating_well_written > 0 OR rating_valid_points > 0 OR rating_agree > 0')
	end

	def commentCount
		12
	end

	def agreeCount
		13
	end

	def disagreeCount
		11
	end
end
