class ExchangesController < ApplicationController
	def index
		# exchange.count > 0 && exchange.has_image? && !exchange.description.nil?
		@exchanges = Exchange.order(:name)
	end

	def show
		@exchange = Exchange.find_by(slug: params[:slug])
	end
end
