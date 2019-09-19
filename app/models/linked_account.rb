class LinkedAccount < ApplicationRecord
	belongs_to	:user
	belongs_to	:linked_account, class_name: 'User'
end
