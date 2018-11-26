class HomeController < ApplicationController
	def index
		Rails.logger.info "sdfsdfsdf ---fwerfi 0w9eru wieur "
		@articles = Article.order(published_at: :desc)
	end
end