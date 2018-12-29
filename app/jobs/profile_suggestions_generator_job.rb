class ProfileSuggestionsGeneratorJob < ApplicationJob
  queue_as :suggestions

  def perform(user, is_new, limit)
  	user.generate_suggestions(is_new, limit)
  end
end
