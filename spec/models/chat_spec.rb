require 'rails_helper'

RSpec.describe Chat do

	let(:chat) { Chat.new }
	let(:first_user_message) { Message.new(id: 1, user_id: 1) }
	let(:second_user_message) { Message.new(id: 2, user_id: 2) }

	before(:each) do
		chat.messages << first_user_message
	end

	it "considers a chat with messages by one user to be unanswered" do
		expect(chat.unanswered?).to be_truthy
		chat.messages << first_user_message
		expect(chat.unanswered?).to be_truthy
	end

	it "considers a chat with messages by both users to be answered" do
		expect(chat.answered?).to be_falsey
		chat.messages << second_user_message
		expect(chat.answered?).to be_truthy
	end

	it "caches the last message id" do
		expect(chat.last_message_id).to eq(first_user_message.id)
		chat.messages << second_user_message
		expect(chat.last_message_id).to eq(second_user_message.id)
	end

	it "caches the message count" do
		chat.messages << second_user_message
		expect(chat.message_count).to eq(chat.messages.size)
	end

	describe "validate" do
		# it "must have at least one message" do
		# 	chat.valid?
		# 	expect(chat.errors.full_messages).to contain("")
		# end
	end
end