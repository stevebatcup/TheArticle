class TheArticle.Footer extends TheArticle.MobilePageController

	@register window.App
	@$inject: ['$scope', '$timeout', '$compile']

	init: ->

TheArticle.ControllerModule.controller('FooterController', TheArticle.Footer)
