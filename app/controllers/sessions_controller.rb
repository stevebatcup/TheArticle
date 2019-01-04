class SessionsController < Devise::SessionsController
	after_action  :generate_profile_suggestions, :only => [:create]
	layout	'profile-wizard'

  def generate_profile_suggestions
   	ProfileSuggestionsGeneratorJob.perform_later(resource, false, 25)
  end
end