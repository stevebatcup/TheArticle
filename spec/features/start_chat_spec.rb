require 'rails_helper'

describe 'starting a chat' do
	let(:opening_gambit) { "Here's a really interesting ice breaker!" }

	it "allows a user to start a chat with by sending a message" do
		visit send_new_message_path
		fill_in "Message", with: opening_gambit
		click_on	"Send message"
		visit chats_path
		expect(:page).to have_content(opening_gambit)
		expect(:page).to have_content("1 Message")
	end
end