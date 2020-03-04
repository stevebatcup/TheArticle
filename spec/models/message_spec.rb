require 'rails_helper'

RSpec.describe Message do

	let(:chat) { Chat.new }
	let(:user) { User.create(first_name: "Mike", last_name: "Smith", email: "steve.batcup+miketest@gmail.com", password: "123123123", confirmed_at: Time.now) }

	describe "validate" do
		describe "must belong to a chat" do
			specify do
				blank_message = Message.new
				blank_message.valid?
				expect(blank_message.errors[:chat]).to include("must belong to a chat")
			end

			specify do
				message = Message.create({ body: "My silly old ice breaker", user: user })
				chat.messages << message
				chat.save
				expect(message.errors[:chat]).to_not include("must belong to a chat")
				expect(message.chat).to be_a(Chat)
			end
		end

		describe "must contain body text" do
			specify do
				first_message = Message.create({ user: user })
				expect(first_message.errors[:body]).to include("must contain text")
			end

			specify do
				second_message = Message.create({ body: "", user: user })
				expect(second_message.errors[:body]).to include("must contain text")
			end
		end
	end
end