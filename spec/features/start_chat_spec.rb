require 'rails_helper'

RSpec.describe 'starting a chat', type: :feature do
	let(:opening_gambit) { "Here's a really interesting ice breaker!" }
	let(:initial_sender) { FactoryGirl.create(:initial_sender) }
	let(:initial_recipient) { FactoryGirl.create(:initial_recipient) }

	before do
		login_as(initial_sender, :scope => :user)
	end

	it "allows a user to start a chat by sending a message" do
		visit new_chat_path(recipient: initial_recipient.id)
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
			text: "Jane Jones"
		)
		expect(page).to have_selector(
			"#chat_#{@chat.id} .message_count",
			text: "1 message"
		)
	end

	describe "existing chat" do
		let(:chat) { FactoryGirl.build(:chat) }

		before do
			chat.initiate_conversers(initial_sender, initial_recipient)
					.add_message(opening_gambit, initial_sender)
			chat.save!
		end

		it "forwards a user to edit the chat if the chat already exists" do
			visit new_chat_path(recipient: initial_recipient.id)
			expect(current_path).to eq(edit_chat_path(chat.id))
			expect(page).to have_selector(
				"h2",
				text: "Edit chat"
			)
		end
	end

end