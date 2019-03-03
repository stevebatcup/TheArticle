class TheArticle.Article extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$rootElement'
	  '$rootScope'
	  '$timeout'
	  '$compile'
	]

	init: ->
		@bindEvents()
		@scope.articlesInSameExchange =
			firstLoaded: true

	bindEvents: ->
		super

TheArticle.ControllerModule.controller('ArticleController', TheArticle.Article)