class UpdateUserOnBibblioJob < ApplicationJob
  queue_as :bibblio

  def perform(user_id, action)
  	user = User.find(user_id)
  	BibblioApiService::Users.new(user).update(action)
  end
end
