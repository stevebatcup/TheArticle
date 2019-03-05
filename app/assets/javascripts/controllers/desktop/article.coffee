class TheArticle.Article extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$element'
	  '$rootScope'
	  '$timeout'
	  '$compile'
	  '$cookies'
	]

	init: ->
		@rootScope.isSignedIn = !!@element.data('signed-in')
		@bindEvents()
		@scope.articlesInSameExchange =
			firstLoaded: true

		if ($('#flash_notice').length > 0) and (@cookies.get('ok_to_flash'))
			@flash $('#flash_notice').html()
			@cookies.remove('ok_to_flash')

	bindEvents: ->
		super

TheArticle.ControllerModule.controller('ArticleController', TheArticle.Article)