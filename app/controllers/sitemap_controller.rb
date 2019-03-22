class SitemapController < ApplicationController
	def index
		respond_to do |format|
			format.xml do
				@pages = Page.all
				@articles = Article.not_remote.order(published_at: :desc)
				@exchanges = Exchange.order(slug: :desc)
				@keyword_tags = KeywordTag.order(article_count: :desc)
				@authors = Author.order(article_count: :desc)
			end
		end
	end
end