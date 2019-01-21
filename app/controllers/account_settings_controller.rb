class AccountSettingsController < ApplicationController
	before_action :authenticate_user!

	def edit
		respond_to do |format|
			format.html do
				sponsored_picks = Author.get_sponsors_single_posts(nil, 3)
				@trending_articles = Article.trending.limit(Author.sponsors.any? ? 4 : 5).all.to_a
				@trending_articles.insert(2, sponsored_picks.first) if Author.sponsors.any?
			end
			format.json
		end
	end

	def update

	end
end