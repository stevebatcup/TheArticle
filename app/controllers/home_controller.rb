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
	end
end