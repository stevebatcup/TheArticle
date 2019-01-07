class TheArticle.Auth extends TheArticle.PageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	]

	init: ->

	bindEvents: ->

TheArticle.ControllerModule.controller('AuthController', TheArticle.Auth)