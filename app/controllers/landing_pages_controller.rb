class LandingPagesController < ApplicationController
	def show
		@desc = "Sign up to TheArticle for all the latest news on Brexit. Register for free to follow topics that interest you and receive relevant articles, from every angle, all delivered to your personal feed - including all our updates on Brexit."
		@tags = KeywordTag.where(name: ['Brexit', 'No-deal', 'Withdrawal agreement', 'Remain', 'Leave']).all.map(&:slug)
	end
end