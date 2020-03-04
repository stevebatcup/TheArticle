require 'rails_helper'

RSpec.describe Chat do

	let(:chat) { Chat.new }
	let(:first_user) { User.create(first_name: "Bob", last_name: "Smith", email: "steve.batcup+bobtest@gmail.com", password: "123123123", confirmed_at: Time.now) }
	let(:second_user) { User.create(first_name: "Jane", last_name: "Smith", email: "foo2@example.com", password: "123123123", confirmed_at: Time.now) }

	def build_chatters
		chat.initiate_conversers(first_user, second_user)
	end

	describe "chatters" do
		it "builds conversers" do
			build_chatters
			expect(chat.conversers.size).to eq(2)
			expect(chat.conversers[0].user.first_name).to eq("Bob")
		end

		it "sets the first user as the chat initiator" do
			build_chatters
			expect(chat.conversers[0].is_chat_initiator?).to be_truthy
		end

		it "does not set the second user as the chat initiator" do
			build_chatters
			expect(chat.conversers[1].is_chat_initiator?).to be_falsey
		end
	end

	describe "messages" do
		before(:each) do
			build_chatters
		end

		def send_ice_breaker
			chat.messages.build({body: "My silly old ice breaker", user: first_user})
			chat.save
		end

		def send_response
			chat.messages.build({body: "My silly old response", user: second_user})
			chat.save
		end

		it "considers a chat without messages by both users to be unanswered" do
			send_ice_breaker
			expect(chat.unanswered?).to be_truthy
		end

		describe "considers a chat with messages by both users to be answered" do
			specify do
				send_ice_breaker
				expect(chat.answered?).to be_falsey
			end

			specify do
				send_ice_breaker
				send_response
				expect(chat.answered?).to be_truthy
			end
		end

		it "caches the last message id" do
			send_ice_breaker
			expect(chat.last_message_id).to eq(chat.messages.last.id)
			send_response
			expect(chat.last_message_id).to eq(chat.messages.last.id)
		end

		it "caches the message count" do
			send_ice_breaker
			send_response
			expect(chat.message_count).to eq(2)
		end

		describe "validate" do
			it "must have at least one message" do
				chat.valid?
				expect(chat.errors[:messages]).to include("must have at least one message")
			end
		end
	end
end