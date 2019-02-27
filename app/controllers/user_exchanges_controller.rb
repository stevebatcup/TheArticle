class UserExchangesController < ApplicationController
	before_action :authenticate_user!, except: [:index]

	def index
		respond_to do |format|
			format.json do
				page = (params[:page] || 1).to_i
				per_page = (params[:per_page] || 6).to_i
				if params[:id]
					@user = User.find(params[:id])
				else
					@user = current_user
				end
				if page == 1
					@total = @user.subscriptions.size
				end
				@subscriptions = @user.subscriptions.page(page).per(per_page).order(created_at: :desc)
			end
		end
	end

	def create
		@exchange = Exchange.find(params[:id])
		current_user.exchanges << @exchange
		if current_user.save
			flash[:notice] = "You are now following the <b>#{@exchange.name}</b> exchange" if params[:set_flash]
			@status = :success
		else
			@status = :error
		end
	end

	def destroy
		subscription = current_user.subscriptions.find_by(exchange_id: params[:id])
		@exchange = subscription.exchange
		if subscription.destroy
			flash[:notice] = "You are no longer following the <b>#{@exchange.name}</b> exchange" if params[:set_flash]
			@status = :success
		else
			@status = :error
		end
	end

	def my_followers_of
		@exchange = Exchange.find(params[:id])
		@followers = current_user.followings.map(&:followed).select! do |my_following|
			@exchange.is_followed_by(my_following)
		end
	end

	def mute
		current_user.mute_exchange(params[:id])
		render json: { status: :success }
	end
end
