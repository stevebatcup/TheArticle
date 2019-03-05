class TheArticle.Article extends TheArticle.MobilePageController

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

	bindEvents: ->
		super

TheArticle.ControllerModule.controller('ArticleController', TheArticle.Article)