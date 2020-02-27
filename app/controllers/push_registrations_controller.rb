class PushRegistrationsController < ApplicationController
	before_action :authenticate_user!

	def create
		respond_to do |format|
			format.json do
				other_user_tokens = PushToken.where.not(user: current_user).where(token: params[:subscription])
				other_user_tokens.destroy_all if other_user_tokens.any?

				unless current_user.push_tokens.find_by(token: params[:subscription])
					current_user.push_tokens << PushToken.new({
						token: params[:subscription],
						device: browser.device.name,
						browser: browser.name,
						created_at: Time.now
			    })
					current_user.save
				end

				@status = :success
			end
		end
	end

	def destroy
		if token = current_user.push_tokens.find_by(token: params[:subscription])
			token.destroy
			@status = :success
		else
			@status = :error
		end
	end
end