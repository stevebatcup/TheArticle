require 'rails_helper'

RSpec.describe 'update a chat', type: :feature do
	let(:chat) { FactoryGirl.build(:chat) }
	let(:initial_sender) { FactoryGirl.build(:initial_sender) }
	let(:initial_recipient) { FactoryGirl.build(:initial_sender) }

	before do
		chat.initiate_conversers(initial_sender, initial_recipient)
				.add_message("First message", initial_sender)
		chat.save!
	end

	it "allows a response from the initial_recipient" do
		login_as(initial_recipient, :scope => :user)
		visit edit_chat_path(chat.id)
		message = "Yes I agree, you old tart!"
		fill_in "Message", with: message
		click_on	"Send message"
		visit chats_path
		expect(page).to have_selector(
			"#chat_#{chat.id} .last_message",
			text: message
		)
	end

	it "allows a second message before the initial_recipient replies" do
		login_as(initial_sender, :scope => :user)
		visit edit_chat_path(chat.id)
		message = "Oh and I forgot to say to you"
		fill_in "Message", with: message
		click_on	"Send message"
		visit chats_path
		expect(page).to have_selector(
			"#chat_#{chat.id} .last_message",
			text: message
		)
	end

	it "allows a response to the first response" do
		chat.add_message("A first response", initial_recipient)
		login_as(initial_sender, :scope => :user)
		visit edit_chat_path(chat.id)
		message = "So glad you got back to me"
		fill_in "Message", with: message
		click_on	"Send message"
		visit chats_path
		expect(page).to have_selector(
			"#chat_#{chat.id} .last_message",
			text: message
		)
	end
end