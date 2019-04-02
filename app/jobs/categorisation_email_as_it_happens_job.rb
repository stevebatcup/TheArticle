class CategorisationEmailAsItHappensJob < ApplicationJob
  queue_as :categorisations

  def perform(user, article, exchange)
  	CategorisationsMailer.as_it_happens(user, article, exchange).deliver_now
  end
end
