class TheArticle.Follows extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
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