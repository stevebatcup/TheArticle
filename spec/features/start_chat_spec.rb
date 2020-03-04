require 'rails_helper'

RSpec.describe 'starting a chat', :type => :feature do
	let(:opening_gambit) { "Here's a really interesting ice breaker!" }
	let(:recipient) { User.create(first_name: "Bob", last_name: "Smith", email: "steve.batcup+recipient@gmail.com", password: "123123123", confirmed_at: Time.now) }

	before do
		user = User.create(first_name: "Monkey", last_name: "Jones", email: "steve.batcup+bobtest@gmail.com", password: "123123123", confirmed_at: Time.now)
		login_as(user, :scope => :user)
	end

	it "allows a user to start a chat by sending a message" do
		visit new_chat_path(recipient: recipient.id)
		fill_in "Message", with: opening_gambit
		click_on	"Send message"
		visit chats_path
		@chat = Chat.includes(:messages).find_by(messages: { body: opening_gambit })
		expect(page).to have_selector(
			"#chat_#{@chat.id} .last_message",
			text: opening_gambit
		)
		expect(page).to have_selector(
			"#chat_#{@chat.id} .name",
			text: "Bob Smith"
		)
		expect(page).to have_selector(
			"#chat_#{@chat.id} .message_count",
			text: "1 message"
		)
	end
end