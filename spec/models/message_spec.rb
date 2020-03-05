require 'rails_helper'

RSpec.describe Message do

	let(:chat) { FactoryGirl.build(:chat) }
	let(:user) { FactoryGirl.build(:initial_sender) }

	describe "validate" do
		describe "must belong to a chat" do
			specify do
				blank_message = FactoryGirl.build(:message)
				blank_message.valid?
				expect(blank_message.errors[:chat]).to include("must belong to a chat")
			end

			specify do
				message = FactoryGirl.build(:ice_breaker, chat: chat)
				message.valid?
				expect(message.errors[:chat]).to_not include("must belong to a chat")
				expect(message.chat).to be_a(Chat)
			end
		end

		describe "must contain body text" do
			specify do
				first_message = FactoryGirl.build(:message, user: user)
				first_message.valid?
				expect(first_message.errors[:body]).to include("must contain text")
			end

			specify do
				second_message = FactoryGirl.build(:message, body: "")
				second_message.valid?
				expect(second_message.errors[:body]).to include("must contain text")
			end
		end
	end
end