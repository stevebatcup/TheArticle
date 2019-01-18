class MutesController < ApplicationController
	def create
		current_user.mutes << Mute.new({muted_id: params[:id], status: :active})
		if current_user.save
			@status = :success
		else
			@status = :error
			@message = current_user.errors.full_messages
		end
	end

	def destroy
		mute = current_user.mutes.where(muted_id: params[:id], status: :active).first
		if mute.present? and mute.update_attribute(:status, :deleted)
			@status = :success
		else
			@status = :error
		end
	end
end
