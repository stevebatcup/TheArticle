class CommentsController < ApplicationController
	def index
		@orderBy = params[:order_by] ||= :most_relevant
		share = Share.find(params[:share_id])
		@comments = Comment.order_list_by(share.root_comments, @orderBy.to_sym, user_signed_in? ? current_user : nil)
	end

	def create
		share = Share.find(params[:comment][:share_id])

		parentComment = nil
		parent_id = params[:comment][:parent].to_i
		parentComment = Comment.find(parent_id) if parent_id > 0

		body = params[:comment][:body]

		if params[:comment][:replying_to_username].length > 0
			other_user = User.find_by(username: params[:comment][:replying_to_username])
			body = "<a href='#{profile_path(slug: other_user.slug)}'>#{other_user.username}</a> #{body}"
		end

		if share.user.has_blocked(current_user)
			return @comment = { status: :error, message: "Sorry you have been blocked by the creator of this post" }
		elsif parentComment.present?
			if parentComment.user.has_blocked(current_user)
				return @comment = { status: :error, message: "Sorry you have been blocked by the user who wrote this comment" }
			end
		end

		comment = Comment.build_from(share, current_user.id, body)
		if comment.save
			@comment = view_context.comment_for_tpl(comment)
			comment.move_to_child_of parentComment
			comment.create_notification
			@comment[:status] = :success
		else
			@comment = { status: :error, message: "Could not create comment" }
		end
	end

	def show
		@comment = Comment.find(params[:id])
	end

	def destroy
		comment = Comment.find(params[:id])
		if params[:ownership] == 'own'
			if comment.user_id == current_user.id
				comment.destroy
				render json: { status: :success }
			else
				render json: { status: :error, message: "You do not have permission to delete this comment" }
			end
		else
			if comment.commentable.user_id == current_user.id
				comment.destroy
				render json: { status: :success }
			else
				render json: { status: :error, message: "You do not have permission to delete this comment" }
			end
		end
	end
end
