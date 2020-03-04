require 'rails_helper'

RSpec.describe CreatesChatService do
	let(:sender) { User.create(first_name: "Bob", last_name: "Smith", email: "steve.batcup+bobtest@gmail.com", password: "123123123", confirmed_at: Time.now) }
	let(:recipient) { User.create(first_name: "Jane", last_name: "Smith", email: "foo2@example.com", password: "123123123", confirmed_at: Time.now) }

	it "does not create a chat without an initial message" do
		creator = CreatesChatService.new(sender, recipient, "")
		creator.create
		expect(creator.chat.errors[:messages]).to_not be_empty
	end

	it "builds a chat with users and an initial message" do
		creator = CreatesChatService.new(sender, recipient, "My silly old ice breaker")
		creator.create
		expect(creator.chat.initiator).to eq(sender)
		expect(creator.chat.messages[0].body).to eq("My silly old ice breaker")
	end
end