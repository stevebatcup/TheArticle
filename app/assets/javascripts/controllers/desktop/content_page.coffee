class TheArticle.ContentPage extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
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