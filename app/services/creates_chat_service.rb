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
		build_first_message # unless first_message_body.empty?
		chat
	end

	def build_first_message
		self.first_message = Message.new({ body: @first_message_body, user: sender })
		chat.messages << first_message
	end

	def create
		build
		chat.save
	end
end