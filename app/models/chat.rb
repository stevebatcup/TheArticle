class Chat < ApplicationRecord
	has_many	:messages, dependent: :destroy
	has_many	:conversers, dependent: :destroy
	has_many	:users, through: :conversers
	validates :messages, length: { minimum: 1, message: 'must have at least one message' }

	def initiate_conversers(sender, recipient)
		self.conversers.build([
			{ user: sender, is_chat_initiator: true },
			{ user: recipient, is_chat_initiator: false }
		])
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

	def update_message_count
		update_attribute(:message_count, messages.size)
	end
end