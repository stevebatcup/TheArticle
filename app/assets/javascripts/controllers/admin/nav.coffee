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
		console.log @rootScope.$id
		@setDefaultHttpHeaders()
		@rootScope.userTabs = []
		@rootScope.pageBoxes = []
		@rootScope.openPageBoxId = 0
		@getOpenPages()

	getOpenPages: =>
		@http.get("/admin/get-open-pages").then (response) =>
			@rootScope.userTabs = response.data.pages


TheArticle.ControllerModule.controller('NavController', TheArticle.Nav)