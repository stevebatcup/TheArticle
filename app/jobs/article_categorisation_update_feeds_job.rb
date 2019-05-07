class ArticleCategorisationUpdateFeedsJob < ApplicationJob
  queue_as :categorisations

  def perform(article)
  	article.update_categorisation_feeds
  end
end
