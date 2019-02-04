class UserConcernReport < ConcernReport
	default_scope	-> { where(sourceable_type: 'User') }
end