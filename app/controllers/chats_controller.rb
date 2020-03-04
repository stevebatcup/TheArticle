class ChatsController < ApplicationController
	def index
		@chats = current_user.chats
	end

	def new
		@chat = Chat.new
		@recipient_id = params[:recipient]
	end

	def create
		recipient = User.find(chat_params[:recipient_id])
		@service = CreatesChatService.new(
				current_user,
				recipient,
				chat_params[:messages][:body])
		if @service.create
			redirect_to chats_path
		else
			@recipient_id = @service.recipient.id
			@chat = @service.chat
			render :new
		end
	end

private
	def chat_params
		params.require(:chat).permit(:recipient_id, messages: [:body])
	end
end
