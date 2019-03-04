class TheArticle.Help extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	]

	init: ->

TheArticle.ControllerModule.controller('HelpController', TheArticle.Help)
