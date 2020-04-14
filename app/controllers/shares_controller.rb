class SharesController < ApplicationController
	before_action :authenticate_user!

	def create
		article = Article.find(share_params[:article_id])
		if share_params[:share_type] == 'rating'
			if rating = current_user.existing_article_rating(article)
				rating.destroy
			end
		end
		@share = Share.new(share_params)
		@share.share_type = Share.determine_share_type(share_params)
		@share.user_id = current_user.id
		if @share.save
			UpdateUserOnBibblioJob.set(wait_until: 5.seconds.from_now).perform_later(current_user.id, "new #{@share.share_type}")  if current_user.on_bibblio?
			flash[:notice] = @message = "Post added to your profile. <a class='text-green' href='/my-profile'>View post</a>.".html_safe
			render json: { status: :success, message: @message }
		else
			render json: { status: :error, message: @share.errors.full_messages.first }
		end
	end

	def show
		@share = Share.find(params[:id])
	end

	def destroy
		share = Share.find(params[:id])
		if share.user_id == current_user.id
			share.destroy
			render json: { status: :success, message: "Post deleted" }
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
		params.require(:share).permit(:article_id, :share_type, :rating_well_written, :rating_valid_points, :rating_agree, :post)
	end
end