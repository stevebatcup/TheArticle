class ThirdPartyArticlesController < ApplicationController
	before_action :authenticate_user!

	def show
		respond_to do |format|
			format.json do
				begin
					@articleOG = ThirdPartyArticleService.scrape_url(article_params[:url])
					@status = :success
				rescue IOError => e
					@message = e.message
					@status = :error
				end
			end
		end
	end

	def create
		begin
			ThirdPartyArticleService.create_from_share(share_params, current_user)
			@status = :success
		rescue Exception => e
			@message = e.backtrace
			@status = :error
		end
	end

	def check_white_list
		host = ThirdPartyArticleService.get_domain_from_url(params[:url])
		if WhiteListedThirdPartyPublisher.find_by(domain: host)
			@status = :found
		else
			@status = :missing
		end
	end

private
	def article_params
		params.require(:article).permit(:url)
	end

	def share_params
		params.require(:share).permit(:post, :rating_well_written, :rating_valid_points, :rating_agree, article: [:url, :title, :snippet, :image, :type, :siteName])
	end
end