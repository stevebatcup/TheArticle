class UserExchangesController < ApplicationController
	before_action :authenticate_user!, except: [:index]

	def index
		if params[:id]
			user = User.find(params[:id])
			@userExchanges = user.exchanges
		else
			@userExchanges = current_user.exchanges
		end
	end

	def create
		exchange = Exchange.find(params[:id])
		current_user.exchanges << exchange
		if current_user.save
			@status = :success
		else
			@status = :error
		end
	end

	def destroy
		exchange = Exchange.find(params[:id])
		if current_user.exchanges.delete(exchange)
			@status = :success
		else
			@status = :error
		end
	end
end
