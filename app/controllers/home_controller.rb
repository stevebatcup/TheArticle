class HomeController < ApplicationController

	def index
		@articles = []
		if user_signed_in? && !params[:force_home]
			redirect_to front_page_path
		end
		@ad_page_type = 'homepage'
		@trending_exchanges = Exchange.trending_list.all.to_a.shuffle
		@sponsored_picks = Author.get_sponsors_single_posts('sponsored-pick').to_a if browser.device.mobile?
		@articles_for_carousel = Article.for_carousel(article_carousel_sponsored_position)
		@contributors_for_spotlight = Author.contributors_for_spotlight
		@recent_articles = Article.recent

		if user_signed_in? && !current_user.has_completed_wizard?
			current_user.display_name = current_user.default_display_name
			current_user.username = current_user.generate_usernames.shuffle.first
			trending_exchanges = Exchange.trending_list
			other_exchanges = Exchange.non_trending.where("slug != 'editor-at-the-article'").order(article_count: :desc)
			@exchanges_for_profile_wizard = trending_exchanges.to_a.concat(other_exchanges)
			@exchanges_for_profile_wizard.unshift(Exchange.editor_item)
		end
	end
end