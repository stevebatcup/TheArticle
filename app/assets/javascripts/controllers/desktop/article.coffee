class TheArticle.Article extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$element'
	  '$rootScope'
	  '$timeout'
	  '$compile'
	]

	init: ->
		@rootScope.isSignedIn = !!@element.data('signed-in')
		@bindEvents()
		@scope.articlesInSameExchange =
			firstLoaded: true

	bindEvents: ->
		super

TheArticle.ControllerModule.controller('ArticleController', TheArticle.Article)