class SharesController < ApplicationController
	before_action :authenticate_user!

	def create
		article = Article.find(share_params[:article_id])
		if share = current_user.article_share(article)
			update(share)
		else
			@share = Share.new(share_params)
			@share.user_id = current_user.id
			if @share.save
				render json: { status: :success }
			else
				render json: { status: :error, message: @share.errors.full_messages.first }
			end
		end
	end

	def show
		@share = Share.find(params[:id])
	end

	def destroy
		share = Share.find(params[:id])
		if share.user_id == current_user.id
			share.destroy
			render json: { status: :success }
		else
			render json: { status: :error, message: "You do not have permission to delete this post" }
		end
	end

private

	def update(share)
		if share.update(share_params)
			render json: { status: :success }
		else
			render json: { status: :error, message: @share.errors.full_messages.first }
		end
	end

	def share_params
		params.require(:share).permit(:article_id, :rating_well_written, :rating_valid_points, :rating_agree, :post)
	end
end