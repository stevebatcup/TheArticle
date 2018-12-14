class ProfileWizardController < ApplicationController
	before_action :authenticate_user!
	layout	'profile-wizard'

	def new
		redirect_to front_page_path if current_user.has_completed_wizard?
		current_user.display_name = current_user.default_display_name
		current_user.username = current_user.generate_usernames.shuffle.first
	end
end