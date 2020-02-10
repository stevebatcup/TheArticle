class TheArticle.ContentPage extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$compile'
	  '$timeout',
	  '$ngConfirm'
	]

	init: ->
		@bindEvents()

	bindEvents: ->
		super

TheArticle.ControllerModule.controller('ContentPageController', TheArticle.ContentPage)