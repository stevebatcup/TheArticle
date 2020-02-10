class AdminEmailUserNewMessageJob < ApplicationJob
  queue_as :admin

  def perform(user, subject, message)
  	AdminMailer.new_message(user, subject, message).deliver_now
  end
end
