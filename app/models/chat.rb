class Chat
	attr_accessor	:messages

	def initialize
		@messages = []
	end

	def user_ids
		@messages.map(&:user_id).uniq
	end

	def unanswered?
		user_ids.size == 1
	end

	def answered?
		user_ids.size > 1
	end

	def last_message_id
		@messages.last.id
	end

	def message_count
		@messages.size
	end

end