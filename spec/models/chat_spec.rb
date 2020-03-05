require 'rails_helper'

RSpec.describe Chat do
	let(:initial_sender) { FactoryGirl.build(:initial_sender) }
	let(:initial_recipient) { FactoryGirl.build(:initial_sender) }

	describe "finders" do
		it "finds a chat by both conversers" do
			initial_sender.save!
			initial_recipient.save!
			chat = FactoryGirl.build(:chat)
			chat.initiate_conversers(initial_sender, initial_recipient)
					.add_message("A first message", initial_sender)
			chat.save!
			found_chat = Chat.find_by_users(initial_sender, initial_recipient)
			expect(found_chat).to be_a(Chat)
			expect(found_chat.id).to eq(chat.id)
		end
	end

	describe "chatters" do
		let(:chat) { FactoryGirl.build(:chat) }

		before(:each) do
			chat.initiate_conversers(initial_sender, initial_recipient)
		end

		it "builds conversers" do
			expect(chat.conversers.size).to eq(2)
			expect(chat.conversers[0].user.first_name).to eq("Bob")
		end

		it "sets the first user as the chat initiator" do
			expect(chat.conversers[0].is_chat_initiator?).to be_truthy
		end

		it "does not set the second user as the chat initiator" do
			expect(chat.conversers[1].is_chat_initiator?).to be_falsey
		end
	end

	describe "messages" do
		let(:unanswered_chat) do
			uc = FactoryGirl.build(:chat) do |c|
				c.messages << FactoryGirl.build(:ice_breaker)
			end
			uc.initiate_conversers(initial_sender, initial_recipient)
			uc
		end
		let(:answered_chat) do
			ac = FactoryGirl.build(:chat) do |chat|
				chat.messages << FactoryGirl.build(:ice_breaker)
				chat.messages << FactoryGirl.build(:first_response)
			end
			ac.initiate_conversers(initial_sender, initial_recipient)
			ac
		end

		it "considers a chat without messages by both users to be unanswered" do
			expect(unanswered_chat.unanswered?).to be_truthy
		end

		describe "considers a chat with messages by both users to be answered" do
			specify { expect(unanswered_chat.answered?).to be_falsey }
			specify { expect(answered_chat.answered?).to be_truthy }
		end

		describe "after saving message(s) update the chat data" do
			let(:chat) { FactoryGirl.build(:chat) }
			let(:ice_breaker) { FactoryGirl.build(:ice_breaker) }
			let(:initial_sender) { FactoryGirl.create(:initial_sender) }
			let(:initial_recipient) { FactoryGirl.create(:initial_sender) }

			before(:each) do
				chat.initiate_conversers(initial_sender, initial_recipient)
				chat.messages << ice_breaker
				chat.save!
			end

			it "caches the message count" do
				FactoryGirl.create(:first_response, chat: chat.reload)
				expect(chat.message_count).to eq(2)
			end

			describe "caches the last message id" do
				specify do
					expect(chat.last_message_id).to_not be_nil
					expect(chat.last_message_id).to eq(ice_breaker.id)
				end

				specify do
					first_response = FactoryGirl.create(:first_response, chat: chat)
					expect(chat.last_message_id).to eq(first_response.id)
				end
			end
		end

		describe "validate" do
			let(:chat) { FactoryGirl.build(:chat) }

			it "must have at least one message" do
				chat.valid?
				expect(chat.errors[:messages]).to include("must have at least one message")
			end
		end
	end
end