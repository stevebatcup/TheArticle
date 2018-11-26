class ArticlesController < ApplicationController
	def show
		@article = Article.find_by(slug: params[:slug])
	end
end
