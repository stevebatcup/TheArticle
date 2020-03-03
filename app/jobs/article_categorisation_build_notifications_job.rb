class ArticleCategorisationBuildNotificationsJob < ApplicationJob
  queue_as :notifications

  def perform(article)
  	Categorisation.build_notifications_for_article(article)
  end
end
