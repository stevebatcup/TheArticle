class AddUserToMailchimpJob < ApplicationJob
  queue_as :users

  def perform(user)
    MailchimperService.subscribe_to_mailchimp_list(user)
  end
end
