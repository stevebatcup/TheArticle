class TheArticle.LandingPage extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$element'
	  '$compile'
	  '$timeout'
	  '$ngConfirm'
	  'LandingPageArticle'
	]

	init: ->
		@signedIn = !!@element.data('signed-in')
		@setDefaultHttpHeaders()

		@scope.articles =
			page: 1
			items: []
			totalItemCount: 0
			firstLoaded: false
			loading: false
			moreToLoad: true
		@bindEvents()
		@getArticles()

	bindEvents: ->
		super()

	loadMore: =>
		@getArticles()

	getArticles: =>
		@scope.articles.loading = true
		timeoutDelay = if @scope.articles.page is 1 then 1200 else 1
		vars = { tagged: @element.data('tags'), page: @scope.articles.page, perPage: @element.data('per-page') }
		@LandingPageArticle.query(vars).then (response) =>
			@timeout =>
				@scope.articles.totalItemCount = response.total if @scope.articles.page is 1
				angular.forEach response.articles, (article) =>
					@scope.articles.items.push article
				@scope.articles.moreToLoad = @scope.articles.totalItemCount > @scope.articles.items.length
				@scope.articles.firstLoaded = true if @scope.articles.page is 1
				@scope.articles.loading = false
				@scope.articles.page += 1
			, timeoutDelay
		, (response) =>
			@refreshPage() if response.status is 401

TheArticle.ControllerModule.controller('LandingPageController', TheArticle.LandingPage)