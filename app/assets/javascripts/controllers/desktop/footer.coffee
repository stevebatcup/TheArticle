class TheArticle.Footer extends TheArticle.DesktopPageController

	@register window.App
	@$inject: ['$scope', '$timeout', '$compile']

	init: ->

TheArticle.ControllerModule.controller('FooterController', TheArticle.Footer)
