class TheArticle.Users extends TheArticle.AdminPageController

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
		@scope.records =
			perPage: Number(@element.data('records-per-page'))
		@watch()

	watch: =>
		@scope.$watch 'records.perPage', (newVal, oldVal) =>
			if (newVal isnt oldVal) and newVal > 0
				@http.get("/admin/set_users_per_page?per_page=#{newVal}").then (response) =>
					window.location.reload()

TheArticle.ControllerModule.controller('UsersController', TheArticle.Users)