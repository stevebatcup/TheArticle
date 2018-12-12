class TheArticle.Follows extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$rootElement'
	  '$timeout'
	  'EditorsPick'
	]

	init: ->
		# console.log "Follows yay!"

TheArticle.ControllerModule.controller('FollowsController', TheArticle.Follows)