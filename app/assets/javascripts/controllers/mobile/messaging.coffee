class TheArticle.Messaging extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$timeout'
	  '$compile'
	]

	init: ->


TheArticle.ControllerModule.controller('MessagingController', TheArticle.Messaging)