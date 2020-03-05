require 'rails_helper'

RSpec.describe ChatsController, type: :controller do
	describe "POST create" do
		let(:initial_sender) { FactoryGirl.create(:initial_sender) }
		let(:initial_recipient) { FactoryGirl.create(:initial_sender) }

		before { allow(controller).to receive(:current_user) { initial_sender } }

		it "raises an error when starting a conversation with a non-user" do
			expect {
				get :new, params: { recipient_id: 12345678 }
			}.to raise_error(ActiveRecord::RecordNotFound)
		end

		it "creates a chat" do
			post :create, params: { chat: { recipient_id: initial_recipient.id, messages: { body: "My silly ice breaking message" } } }
			expect(response).to redirect_to(chats_path)
			expect(assigns[:service].first_message.body).to eq("My silly ice breaking message")
		end

		it "goes back to the form on failure" do
			post :create, params: { chat: { recipient_id: initial_recipient.id, messages: { body: "" } } }
			expect(response).to render_template(:new)
			expect(assigns[:service]).to be_present
		end
	end
end
