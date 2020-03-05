class Chat < ApplicationRecord
	has_many	:messages, dependent: :destroy
	has_many	:conversers, dependent: :destroy
	has_many	:users, through: :conversers
	validates :messages, length: { minimum: 1, message: 'must have at least one message' }

	def initiate_conversers(sender, recipient)
		self.conversers << Converser.new({ user: sender, is_chat_initiator: true })
		self.conversers << Converser.new({ user: recipient, is_chat_initiator: false })
		self
	end

	def add_message(text, sender)
		message = Message.new({ body: text, user: sender })
		self.messages << message
		message
	end

	def other_user(me)
		self.conversers.detect { |c| c.user.id != me.id }.user
	end

	def initiator
		self.conversers.detect { |c| c.is_chat_initiator == true }.user
	end

	def senders
		messages.map(&:user_id)
	end

	def unanswered?
		senders.size < 2
	end

	def answered?
		senders.size == 2
	end

	def update_last_message_id(id)
		update_attribute(:last_message_id, id)
	end

	def update_message_count
		update_attribute(:message_count, messages.size)
	end

	def self.find_by_users(sender, recipient)
		chats = joins(:conversers)
							.where(conversers: { user_id: [sender.id, recipient.id] })
							.group(:chat_id)
							.having('COUNT(*) = 2')
		chats.any? ? chats.first : nil
	end
end