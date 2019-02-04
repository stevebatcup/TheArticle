class CommentConcernReport < ConcernReport
	default_scope	-> { where(sourceable_type: 'Comment') }
end