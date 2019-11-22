class LandingPagesController < ApplicationController
	def show
		if request.path == '/latest-on-brexit'
			@title = "Latest on Brexit"
			@articles_heading = "Latest articles on Brexit"
			@desc = "<b>Sign up to TheArticle for all the latest news on Brexit</b><br /><br /> Register for free to follow topics that interest you and receive relevant articles, from every angle, all delivered to your personal feed &mdash; including all our updates on Brexit."
			@tags = KeywordTag.where(name: ['Brexit', 'No-deal', 'Withdrawal agreement', 'Remain', 'Leave']).all.map(&:slug)
		elsif request.path == '/2019-general-election'
			@title = "2019 General Election"
			@articles_heading = "Latest articles on the 2019 General Election"
			@desc = "<b>Sign up to TheArticle for all the latest news on the 2019 General Election</b><br /><br /> Register for free to follow topics that interest you and receive relevant articles, from every angle, all delivered to your personal feed &mdash; including all our General Election updates."
			@tags = KeywordTag.where(name: ['2019 General Election', 'Leaders debate', 'Boris Johnson', 'Jeremy Corbyn', 'Labour Party', 'Conservative Party', 'Manifesto']).all.map(&:slug)
		end
	end
end