class ChatsController < ApplicationController
	def index
		@chats = current_user.chats
	end

	def new
		@recipient = User.find(params[:recipient])
		if existing_chat = Chat.find_by_users(current_user, @recipient)
			redirect_to edit_chat_path(existing_chat)
		else
			@chat = Chat.new
		end
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
			@recipient = @service.recipient
			@chat = @service.chat
			render :new
		end
	end

	def edit
		@chat = Chat.find(params[:id])
		@recipient = @chat.other_user(current_user)
	end

	def update
		@chat = Chat.find(params[:id])
		@chat.add_message(chat_params[:messages][:body], current_user)
		if @chat.save
			flash.now[:notice] = "Message sent"
			@recipient = @chat.other_user(current_user)
			render :edit
		else
			redirect_to edit_chat_path(@chat)
		end
	end

private
	def chat_params
		params.require(:chat).permit(:recipient_id, messages: [:body])
	end
end