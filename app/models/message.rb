class Message
	attr_accessor	:chat, :user_id, :id

	def initialize(options = {})
		@id = options[:id]
		@user_id = options[:user_id]
	end
end