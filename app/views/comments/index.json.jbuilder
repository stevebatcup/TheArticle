json.set! :comments do
	json.array! @share.root_comments do |root_comment|
		json.data comment_for_tpl(root_comment)
		json.set! :children do
			json.array! root_comment.children do |child_comment|
				json.data comment_for_tpl(child_comment)
			end
		end
	end
end
