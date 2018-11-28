class ArticlesController < ApplicationController
	def show
		@article = Article.find_by(id: params[:id]) or not_found
	end
end
