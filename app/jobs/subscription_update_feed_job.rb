class SubscriptionUpdateFeedJob < ApplicationJob
  queue_as :users

  def perform(subscription)
  	subscription.update_feed
  end
end
