class HomeController < ApplicationController

	def index
		@articles = []
		if user_signed_in? && !params[:force_home]
			redirect_to front_page_path
		end
		@ad_page_type = 'homepage'
		@exchanges_for_tabs = Exchange.most_recent_articles(['editor-at-the-article', 'sponsored'])

		if user_signed_in? && !current_user.has_completed_wizard?
			current_user.display_name = current_user.default_display_name
			current_user.username = current_user.generate_usernames.shuffle.first unless current_user.username.present?
			trending_exchanges = Exchange.trending_list
			other_exchanges = Exchange.non_trending.where("slug != 'editor-at-the-article'").order(article_count: :desc)
			@exchanges_for_profile_wizard = trending_exchanges.to_a.concat(other_exchanges)
		end
	end
end