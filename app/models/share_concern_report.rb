class ShareConcernReport < ConcernReport
	default_scope	-> { where(sourceable_type: 'Share') }
end