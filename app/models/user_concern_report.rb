class UserConcernReport < ConcernReport
	default_scope	-> { where(sourceable_type: 'User').where(status: :pending) }
end