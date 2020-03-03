class ArticleCategorisationSendEmailsJob < ApplicationJob
  queue_as :emails

  def perform(article)
  	article.send_categorisation_email_notifications
  end
end
