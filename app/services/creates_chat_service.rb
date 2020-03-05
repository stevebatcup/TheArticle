class CreatesChatService
	attr_accessor	:chat, :sender, :recipient, :first_message

	def initialize(sender, recipient, first_message_body="")
		@sender = sender
		@recipient = recipient
		@first_message_body = first_message_body
	end

	def build
		self.chat = Chat.new
		chat.initiate_conversers(sender, recipient)
		self.first_message = chat.add_message(@first_message_body, sender)
		chat
	end

	def create
		build
		chat.save
	end
end