require 'rails_helper'

RSpec.describe Message do

	let(:chat) { Chat.new }
	let(:message) { Message.new(user_id: 1) }

	# describe "validate" do
	# 	it "must belong to a chat" do
	# 		expect(message.chat).to be_nil
	# 		chat.messages << message
	# 		expect(message.chat).to be_a(Chat)
	# 	end

	# 	it "must contain body text" do
	# 		chat = Chat.new
	# 		chat.valid?
	# 		expect(chat.errors.full_messages).to contain("")
	# 	end
	# end
end