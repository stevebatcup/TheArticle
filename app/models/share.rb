class Share < ApplicationRecord
	validates_presence_of	:article_id, :user_id
	belongs_to	:user
	belongs_to	:article
end
