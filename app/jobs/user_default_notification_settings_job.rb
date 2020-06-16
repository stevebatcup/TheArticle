class UserDefaultNotificationSettingsJob < ApplicationJob
  queue_as :users

  def perform(user)
  	user.set_default_notification_settings
  end
end
