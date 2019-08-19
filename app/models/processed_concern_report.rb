class ProcessedConcernReport < ConcernReport
	default_scope	-> { where(status: [:seen]) }
end