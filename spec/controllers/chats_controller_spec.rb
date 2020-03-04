require 'rails_helper'

RSpec.describe ChatsController, type: :controller do
	describe "POST create" do
		let(:sender) { User.create(first_name: "Bob", last_name: "Smith", email: "steve.batcup+bobtest@gmail.com", password: "123123123", confirmed_at: Time.now) }
		let(:recipient) { User.create(first_name: "Jane", last_name: "Smith", email: "foo2@example.com", password: "123123123", confirmed_at: Time.now) }

		before { allow(controller).to receive(:current_user) { sender } }

		it "creates a chat" do
			post :create, params: { chat: { recipient_id: recipient.id, messages: { body: "My silly ice breaking message" } } }
			expect(response).to redirect_to(chats_path)
			expect(assigns[:service].first_message.body).to eq("My silly ice breaking message")
		end

		it "goes back to the form on failure" do
			post :create, params: { chat: { recipient_id: recipient.id, messages: { body: "" } } }
			expect(response).to render_template(:new)
			expect(assigns[:service]).to be_present
		end
	end
end
