class TheArticle.Auth extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$rootElement'
	  '$timeout'
	  '$compile'
	]

	init: ->

TheArticle.ControllerModule.controller('AuthController', TheArticle.Auth)