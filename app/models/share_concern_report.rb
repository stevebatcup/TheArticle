class ShareConcernReport < ConcernReport
	default_scope	-> { where(sourceable_type: 'Share').where(status: :pending) }
end