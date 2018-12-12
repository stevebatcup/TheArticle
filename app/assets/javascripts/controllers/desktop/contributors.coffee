class TheArticle.Contributors extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$rootElement'
	  '$timeout'
	  'EditorsPick'
	]

	init: ->
		@bindEvents()

	bindEvents: ->
		super

TheArticle.ControllerModule.controller('ContributorsController', TheArticle.Contributors)