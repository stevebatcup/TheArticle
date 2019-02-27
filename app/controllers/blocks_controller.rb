class BlocksController < ApplicationController
	before_action :authenticate_user!

	def index
		@blocks = current_user.blocked_list
	end

	def create
		blocked_user = User.find(params[:id])
		current_user.blocks << Block.new({blocked_id: params[:id], status: :active})
		if current_user.save
			flash[:notice] = "You have blocked <b>#{blocked_user.username}</b>" if params[:set_flash]
			@status = :success
		else
			@status = :error
			@message = current_user.errors.full_messages
		end
	end

	def destroy
		blocked_user = User.find(params[:id])
		block = current_user.blocks.where(blocked_id: params[:id], status: :active).first
		if block.present? && block.update_attribute(:status, :deleted)
			flash[:notice] = "You have unblocked <b>#{blocked_user.username}</b>" if params[:set_flash]
			@status = :success
		else
			@status = :error
		end
	end
end
