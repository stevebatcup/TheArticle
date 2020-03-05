class Message < ApplicationRecord
	belongs_to	:chat
	belongs_to	:user
	after_create	:update_chat_data
	validates_presence_of :body

	def update_chat_data
		update_chat_last_message_id
		update_chat_message_count
	end

	def update_chat_last_message_id
		chat.update_last_message_id(id)
	end

	def update_chat_message_count
		chat.update_message_count
	end
end