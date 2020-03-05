FactoryGirl.define do
	sequence :email do |n|
		"article_user_#{n}@test.com"
	end

	factory :initial_sender, class: User do
		first_name "Bob"
		last_name "Smith"
		email
		password "123wer345123tyu"
		confirmed_at 4.days.ago
	end

	factory :initial_recipient, class: User do
		first_name "Jane"
		last_name "Jones"
		email
		password "l2kj3k42k3j42mlsdjn"
		confirmed_at 12.days.ago
	end
end