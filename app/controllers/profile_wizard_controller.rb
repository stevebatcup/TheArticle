class ProfileWizardController < ApplicationController
	before_action :authenticate_user!
	layout	'profile-wizard'

	def new
		redirect_to front_page_path(wizard_already_complete: true) if current_user.has_completed_wizard?
		current_user.display_name = current_user.default_display_name
		current_user.username = current_user.generate_usernames.shuffle.first

		trending_exchanges = Exchange.trending_list
		other_exchanges = Exchange.non_trending.where("slug != 'editor-at-the-article'").order(article_count: :desc)
		@exchanges = trending_exchanges.to_a.concat(other_exchanges)
		@exchanges.unshift(Exchange.editor_item)
	end

	def create
		begin
			current_user.complete_profile_from_wizard(params[:profile])
			ProfileSuggestionsGeneratorJob.perform_later(current_user, false, 25)
			@status = :success
			@redirect = front_page_path(from_wizard: true)
		rescue Exception => e
			@status = :error
			@error = e.message
		end
	end
end