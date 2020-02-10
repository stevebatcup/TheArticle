class AdminEmailUserBioUpdatedJob < ApplicationJob
  queue_as :admin

  def perform(user)
  	AdminMailer.bio_updated(user).deliver_now
  end
end
