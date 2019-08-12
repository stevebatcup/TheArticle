class PushRegistrationsController < ApplicationController
	before_action :authenticate_user!

	def create
		respond_to do |format|
			format.json do
				unless current_user.push_tokens.find_by(token: params[:subscription])
					current_user.push_tokens << PushToken.new({
						token: params[:subscription],
						device: browser.device.name,
						browser: browser.name,
						created_at: Time.now
			    })
					if current_user.save
						@status = :success
					else
						@status = :error
					end
				end
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