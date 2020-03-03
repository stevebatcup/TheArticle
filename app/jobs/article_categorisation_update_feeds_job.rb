class ArticleCategorisationUpdateFeedsJob < ApplicationJob
  queue_as :feeds

  def perform(article)
  	article.update_categorisation_feeds
  end
end
