class TheArticle.Help extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	]

	init: ->
		@bindEvents()

	bindEvents: =>
		super

TheArticle.ControllerModule.controller('HelpController', TheArticle.Help)
