class MutesController < ApplicationController
	before_action :authenticate_user!

	def index
		@mutes = current_user.muted_list
	end

	def create
		muted_user = User.find(params[:id])
		current_user.mutes << Mute.new({muted_id: params[:id], status: :active})
		if current_user.save
			flash[:notice] = "You have muted <b>#{muted_user.username}</b>" if params[:set_flash]
			@status = :success
		else
			@status = :error
			@message = current_user.errors.full_messages
		end
	end

	def destroy
		muted_user = User.find(params[:id])
		mute = current_user.mutes.where(muted_id: params[:id], status: :active).first
		if mute.present? and mute.update_attribute(:status, :deleted)
			flash[:notice] = "You have unmuted <b>#{muted_user.username}</b>" if params[:set_flash]
			@status = :success
		else
			@status = :error
		end
	end
end
