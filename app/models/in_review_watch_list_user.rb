class InReviewWatchListUser < WatchListUser
	default_scope	-> { where(status: :in_review) }
end