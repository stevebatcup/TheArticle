class ProfileWizardController < ApplicationController
	before_action :authenticate_user!
	layout	'profile-wizard'

	def new
	end
end