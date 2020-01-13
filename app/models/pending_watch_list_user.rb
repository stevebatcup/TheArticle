class PendingWatchListUser < WatchListUser
	default_scope	-> { where(status: :pending) }
end