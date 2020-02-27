class ThirdPartyArticlesController < ApplicationController
	before_action :authenticate_user!

	def show
		respond_to do |format|
			format.json do
				begin
					@article_open_graph = ThirdPartyArticleService.scrape_url(article_params[:url], current_user)
					@previous_rated_article = Share.find_previous_remote_share_for_user(article_params[:url], current_user)
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
			if previous_rated_article = Share.find_previous_remote_share_for_user(share_params[:url], current_user)
				share = previous_rated_article.shares.first
				share.update_third_party_rating(share_params[:post], share_params[:rating_well_written], share_params[:rating_valid_points], share_params[:rating_agree])
				@status = :success
			elsif ThirdPartyArticleService.share_is_thearticle_domain(share_params[:url], request.host)
				slug = ThirdPartyArticleService.get_slug_from_url(share_params[:url])
				if article = Article.find_by(slug: slug)
					Share.create_or_replace(article, current_user, share_params[:post], share_params[:rating_well_written], share_params[:rating_valid_points], share_params[:rating_agree])
					@status = :success
				else
					@status = :error
					@message = "TheArticle: article not found (#{slug})"
				end
			else
				ThirdPartyArticleService.create_from_share(share_params, current_user)
				@status = :success
			end
		rescue Exception => e
			@message = e.message
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
		params.require(:share).permit(:url, :post, :rating_well_written, :rating_valid_points, :rating_agree, article: [:url, :title, :snippet, :image, :type, :siteName, :domain])
	end
end
