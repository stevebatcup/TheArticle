class ArticleCategorisationSendBrowserPushesJob < ApplicationJob
  queue_as :pushes

  def perform(article)
  	Categorisation.send_browser_pushes_for_article(article)
  end
end
