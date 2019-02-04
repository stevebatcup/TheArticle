class TheArticle.User extends TheArticle.AdminPageController

	@register window.App
	@$inject: [
	  '$scope'
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
		@scope.user =
			id: @element.data('id')
			name: @element.data('name')
			status: @element.data('status')
			blacklisted: @element.data('black-listed')
			watchlisted: @element.data('watch-listed')
			deactivated: @element.data('status') is 'deactivated'
			deleted: @element.data('status') is 'deleted'

	addToBlackList: ($event) =>
		$event.preventDefault()
		@http.get("/admin/add_user_to_blacklist?user_id=#{@scope.user.id}").then (response) =>
			@scope.user.blacklisted = true

	addToWatchList: ($event) =>
		$event.preventDefault()
		@http.get("/admin/add_user_to_watchlist?user_id=#{@scope.user.id}").then (response) =>
			@scope.user.watchlisted = true

	deactivate: ($event) =>
		$event.preventDefault()
		@http.get("/admin/deactivate_user?user_id=#{@scope.user.id}").then (response) =>
			@scope.user.status = 'deactivated'
			@scope.user.deactivated = true

	reactivate: ($event) =>
		$event.preventDefault()
		@http.get("/admin/reactivate_user?user_id=#{@scope.user.id}").then (response) =>
			@scope.user.status = 'active'
			@scope.user.deactivated = false

	delete: ($event) =>
		$event.preventDefault()
		q = "Are you sure you wish to delete #{@scope.user.name}'s account?"
		@confirm q, @deleteConfirm, null, "Sure?", ["No", "Yes, delete"]

	deleteConfirm: =>
		@http.delete("/admin/delete_user?user_id=#{@scope.user.id}").then (response) =>
			@scope.user.status = 'deleted'
			@scope.user.deleted = true


TheArticle.ControllerModule.controller('UserController', TheArticle.User)