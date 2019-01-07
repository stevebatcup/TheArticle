class TheArticle.Auth extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$rootElement'
	  '$timeout'
	  'EditorsPick'
	]

	init: ->

TheArticle.ControllerModule.controller('AuthController', TheArticle.Auth)