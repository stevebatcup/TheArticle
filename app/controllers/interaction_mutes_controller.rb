class InteractionMutesController < ApplicationController
	before_action :authenticate_user!

	def create
		im = current_user.interaction_mutes.create({share_id: params[:share_id]})
		if im
			render	json: { status: :success }
		else
			render	json: { status: :error }
		end
	end

	def destroy
		im = current_user.interaction_mutes.where(share_id: params[:share_id]).first
		if im.present?
			im.destroy
			render	json: { status: :success }
		else
			render	json: { status: :success, message: "Not found" }
		end
	end
end