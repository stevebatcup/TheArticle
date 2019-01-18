class TheArticle.Auth extends TheArticle.PageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$compile'
	]

	init: ->

	bindEvents: ->

TheArticle.ControllerModule.controller('AuthController', TheArticle.Auth)