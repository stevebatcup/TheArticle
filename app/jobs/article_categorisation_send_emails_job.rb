class ArticleCategorisationSendEmailsJob < ApplicationJob
  queue_as :categorisations

  def perform(article)
  	article.send_categorisation_email_notifications
  end
end
