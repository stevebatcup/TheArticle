class TheArticle.Messaging extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$element'
	  '$timeout'
	]

	init: ->


TheArticle.ControllerModule.controller('MessagingController', TheArticle.Messaging)