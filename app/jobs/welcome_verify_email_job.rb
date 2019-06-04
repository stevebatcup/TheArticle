class WelcomeVerifyEmailJob < ApplicationJob
  queue_as :welcome

  def perform(user, token)
  	UserMailer.send_welcome_verify(user, token).deliver_now
  end
end
