comments = []
@comments.each do |root_comment|
	unless user_signed_in? && current_user.is_comment_disallowed?(root_comment)
		# main comment
		item = { data: comment_for_tpl(root_comment) }

		# child comments
		item[:children] = [] if root_comment.children.any?
		root_comment.children.each do |child_comment|
			unless user_signed_in? && current_user.is_comment_disallowed?(child_comment)
				item[:children] << { data: comment_for_tpl(child_comment) }
			end
		end

		comments << item
	end
end
json.comments comments