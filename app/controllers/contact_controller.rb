class ContactController < ApplicationController
	def new
	end

	def create
		is_banned = banned_words.any? do |banned_word|
			params[:message].downcase.include?(banned_word) || params[:subject].downcase.include?(banned_word)
		end
		if is_banned
			render json: { status: 'error', message: 'Contains banned words' }
		else
			ContactMailer.contact(params).deliver_now
			render json: { status: 'success' }
		end
	end

private

	def banned_words
		[
			"bitcoin",
			"cryptocurrency",
			"sex",
			"sexy",
			"beautiful girls",
			"д",
			"й",
			"я",
			"п",
			"ц",
			"и",
			"л",
			"л",
			"Д",
			"ю",
			"ж",
			"б",
			"ы",
			"д",
			"ф",
			"ч"
		]
	end
end