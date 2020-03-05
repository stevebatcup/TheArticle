FactoryGirl.define do
	factory :chat
	factory :message

	factory :ice_breaker, parent: :message do
		body "My silly old ice breaker"
		association :user, factory: :initial_sender, strategy: :build_stubbed
	end

	factory :first_response, parent: :message do
		body "My ridiculous response to your silly old ice breaker"
		association :user, factory: :initial_recipient, strategy: :build_stubbed
	end
end