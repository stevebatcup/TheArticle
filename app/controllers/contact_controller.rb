class ContactController < ApplicationController
	def new
	end

	def create
		is_banned = ["bitcoin", "cryptocurrency"].any? do |banned_word|
			params[:message].downcase.include?(banned_word) || params[:subject].downcase.include?(banned_word)
		end
		if is_banned
			render json: { status: 'error', message: 'Contains banned words' }
		else
			ContactMailer.contact(params).deliver_now
			render json: { status: 'success' }
		end
	end
end