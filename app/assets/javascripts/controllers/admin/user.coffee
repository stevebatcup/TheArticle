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
		@scope.user =
			blacklisted: false

	addToBlackList: ($event, userId) =>
		$event.preventDefault()
		@http.get("/admin/add_user_to_blacklist?user_id=#{userId}").then (response) =>
			@scope.user.blacklisted = true


TheArticle.ControllerModule.controller('UserController', TheArticle.User)