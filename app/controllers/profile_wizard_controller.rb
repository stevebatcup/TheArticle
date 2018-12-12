class ProfileWizardController < ApplicationController
	before_action :authenticate_user!
	layout	'profile-wizard'

	def new
		redirect_to front_page_path if current_user.has_completed_wizard?
	end
end