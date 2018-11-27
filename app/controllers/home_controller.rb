class HomeController < ApplicationController
	def index
		@trending_exchanges = Exchange.trending_list
		@articles_for_carousel = Article.for_carousel(article_carousel_sponsored_position)
		@articles = Article.editors_picks.all.to_a
		if leading_article = Article.leading_editor_article
			@articles.unshift(leading_article)
		end
	end
end