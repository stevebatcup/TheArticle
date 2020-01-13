class TheArticle.WatchListUser extends TheArticle.AdminPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$compile'
	  '$timeout'
	  '$compile'
	  '$ngConfirm'
	]

	init: ->
		@setDefaultHttpHeaders()
		@setCsrfTokenHeaders()

	removeItem: ($event, id, itemType) =>
		$event.preventDefault()
		q = "Are you sure you wish to remove this user from the watchlist?"
		@confirm q, =>
			@confirmRemoveItem(id, itemType)
		, null, "Are you sure?", ["No", "Yes, remove it"]

	confirmRemoveItem: (id, itemType) =>
		@http.delete("/admin/remove_from_watch_list/#{id}").then (response) =>
			if response.data.status is 'success'
				@removeItemSuccess(itemType)
			else if response.data.status is 'error'
				@removeItemError(response.data.message)
		, (error) =>
			@removeItemError(error.statusText)

	removeItemSuccess: (itemType) =>
		@redirectToIndexPage(itemType)

	removeItemError: (msg) =>
		@alert "Error removing watchlist item: #{msg}", "Error"

	deleteAccount: ($event, id, itemType) =>
		$event.preventDefault()
		q = "Are you sure you wish to delete this account?"
		@confirm q, =>
			@confirmDeleteAccount(id, itemType)
		, null, "Are you sure?", ["No", "Yes, delete it"]

	confirmDeleteAccount: (id, itemType) =>
		@http.delete("/admin/delete_watch_list_account/#{id}").then (response) =>
			if response.data.status is 'success'
				@deleteAccountSuccess(itemType)
			else if response.data.status is 'error'
				@deleteAccountError(response.data.message)
		, (error) =>
			@deleteAccountError(error.statusText)

	deleteAccountSuccess: (itemType) =>
		@redirectToIndexPage(itemType)

	deleteAccountError: (msg) =>
		@alert "Error deleting account: #{msg}", "Error"

	sendToReview: ($event, id) =>
		$event.preventDefault()
		q = "Are you sure you wish to send this into review?"
		@confirm q, =>
			@confirmSendToReview(id)
		, null, "Are you sure?", ["No", "Yes, send it"]

	confirmSendToReview: (id) =>
		@http.post("/admin/send_watch_list_item_to_review/#{id}").then (response) =>
			if response.data.status is 'success'
				@sendToReviewSuccess()
			else if response.data.status is 'error'
				@sendToReviewError(response.data.message)
		, (error) =>
			@sendToReviewError(error.statusText)

	sendToReviewSuccess: =>
		@redirectToIndexPage('pending')

	sendToReviewError: (msg) =>
		@alert "Error sending watchlist item for review: #{msg}", "Error"

	redirectToIndexPage: (itemType) =>
		window.location.href = "/admin/#{itemType}_watch_list_users"

TheArticle.ControllerModule.controller('WatchListUserController', TheArticle.WatchListUser)