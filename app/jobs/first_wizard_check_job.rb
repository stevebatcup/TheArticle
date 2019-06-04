class FirstWizardCheckJob < ApplicationJob
  queue_as :welcome

  def perform(user_id)
  	user = User.find(user_id) # reload the user
  	if user && user.has_active_status? && !user.has_completed_wizard
	  	UserMailer.send_first_wizard_nudge(user).deliver_now
	  end
  end
end
