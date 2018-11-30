class HomeController < ApplicationController
	def index
		@ad_page_type = 'homepage'
		@trending_exchanges = Exchange.trending_list
		@articles_for_carousel = Article.for_carousel(article_carousel_sponsored_position)
		@articles = Article.editors_picks.all.to_a
		if leading_article = Article.leading_editor_article
			@articles.unshift(leading_article)
		end
		@sponsored_picks = Author.get_sponsors_single_posts('sponsored-pick')
		@contributors_for_spotlight = Author.contributors_for_spotlight
		@recent_articles = Article.recent
	end
end