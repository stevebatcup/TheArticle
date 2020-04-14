class TheArticle.Follows extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$rootElement'
	  '$timeout'
	  '$compile'
	  'EditorsPick'
	]

	init: ->
		@bindEvents()

TheArticle.ControllerModule.controller('FollowsController', TheArticle.Follows)