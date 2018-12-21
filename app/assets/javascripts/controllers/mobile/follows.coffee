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
		@signedIn = !!@element.data('signed-in')
		if @signedIn
			@setDefaultHttpHeaders()
			@getMyFollows()

TheArticle.ControllerModule.controller('FollowsController', TheArticle.Follows)