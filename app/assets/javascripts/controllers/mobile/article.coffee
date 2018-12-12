class TheArticle.Article extends TheArticle.MobilePageController

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

TheArticle.ControllerModule.controller('ArticleController', TheArticle.Article)