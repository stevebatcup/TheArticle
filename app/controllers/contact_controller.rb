class ContactController < ApplicationController
	layout	:set_layout

	def new
	end

	def create
		ContactMailer.contact(params).deliver_now
		render json: { status: 'success' }
	end
end