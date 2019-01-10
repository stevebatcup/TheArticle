class CommentsController < ApplicationController
	def index
		@share = Share.find(params[:share_id])
	end

	def create
		share = Share.find(params[:comment][:share_id])
		parent_id = params[:comment][:parent].to_i
		body = params[:comment][:body]
		if params[:comment][:replying_to_username].length > 0
			other_user = User.find_by(username: params[:comment][:replying_to_username])
			body = "<a href='#{profile_path(slug: other_user.slug)}'>#{other_user.username}</a> #{body}"
		end
		comment = Comment.build_from(share, current_user.id, body)
		if comment.save
			@comment = view_context.comment_for_tpl(comment)
			comment.move_to_child_of Comment.find(parent_id) if parent_id > 0
			@comment[:status] = :success
		else
			@comment = { status: :error, message: "Could not create comment" }
		end
	end
end
