class TheArticle.Nav extends TheArticle.AdminPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$rootElement'
	  '$compile'
	  '$timeout'
	  '$compile'
	  '$ngConfirm'
	]

	init: ->
		@setDefaultHttpHeaders()
		@rootScope.userTabs = []
		@rootScope.pageBoxes = []
		@getOpenPages()

	getOpenPages: =>
		@http.get("/admin/get-open-pages").then (response) =>
			@rootScope.userTabs = response.data.pages


TheArticle.ControllerModule.controller('NavController', TheArticle.Nav)