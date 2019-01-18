class BlocksController < ApplicationController
	def create
		current_user.blocks << Block.new({blocked_id: params[:id], status: :active})
		if current_user.save
			@status = :success
		else
			@status = :error
			@message = current_user.errors.full_messages
		end
	end

	def destroy
		block = current_user.blocks.where(blocked_id: params[:id], status: :active).first
		if block.present? && block.update_attribute(:status, :deleted)
			@status = :success
		else
			@status = :error
		end
	end
end
