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
		console.log "Follows Desktop yay!"

TheArticle.ControllerModule.controller('FollowsController', TheArticle.Follows)