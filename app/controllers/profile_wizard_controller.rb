class ProfileWizardController < ApplicationController
	before_action :authenticate_user!
	layout	:profile_wizard_layout_for_mobile

	def new
		redirect_to front_page_path(wizard_already_complete: true) if current_user.has_completed_wizard?
		current_user.display_name = current_user.default_display_name
		current_user.username = current_user.generate_usernames.shuffle.first unless current_user.username.present?

		trending_exchanges = Exchange.trending_list
		other_exchanges = Exchange.non_trending.where("slug != 'editor-at-the-article'").order(article_count: :desc)
		@exchanges = trending_exchanges.to_a.concat(other_exchanges)
	end

	def create
		begin
			current_user.complete_profile_from_wizard(params[:profile])
			PendingFollow.process_for_user(current_user)
			sign_in(current_user)
			@status = :success
			@redirect = "#{front_page_path}?from_wizard=1"
		rescue Exception => e
			@status = :error
			@error = e.message
		end
	end

	def save_exchanges
		current_user.subscriptions.destroy_all
		exchanges = []
		params[:ids].each do |eid|
			exchanges << Exchange.find(eid)
		end
		editor_exchange = Exchange.editor_item
		exchanges << editor_exchange
		current_user.exchanges = exchanges
		current_user.save
	end
end