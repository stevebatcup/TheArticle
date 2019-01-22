class TheArticle.Auth extends TheArticle.PageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$compile'
	  '$timeout'
	]

	init: ->

	bindEvents: ->

TheArticle.ControllerModule.controller('AuthController', TheArticle.Auth)