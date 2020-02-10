class AdminEmailUserNewPhotoJob < ApplicationJob
  queue_as :admin

  def perform(user, photo_type)
  	AdminMailer.new_photo(user, photo_type).deliver_now
  end
end
