class TheArticle.Auth extends TheArticle.PageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$rootElement'
	  '$element'
	  '$timeout'
	  '$ngConfirm'
	  '$compile'
	]

	init: ->
		@setDefaultHttpHeaders()
		@bindEvents()

	bindEvents: ->
		@bindCookieAcceptance()

TheArticle.ControllerModule.controller('AuthController', TheArticle.Auth)