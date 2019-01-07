class TheArticle.Article extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$rootElement'
	  '$compile'
	  '$timeout'
	  '$compile'
	]

	init: ->
		@bindEvents()

	bindEvents: ->
		super

TheArticle.ControllerModule.controller('ArticleController', TheArticle.Article)