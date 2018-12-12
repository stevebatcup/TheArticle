class TheArticle.Exchanges extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$rootElement'
	  '$timeout'
	  'ExchangeArticle'
	]

	init: ->
		@bindEvents()
		@scope.moreToLoad = true
		@scope.page = 1
		@scope.exchangeArticles = []
		@scope.totalExchangeArticles = 0
		@scope.loaded = false
		@scope.exchange = @rootElement.data('exchange')
		@getArticles()

	bindEvents: ->
		super

	loadMore: =>
		@getArticles()

	getArticles: =>
		timeoutDelay = if @scope.page is 1 then 1000 else 1
		vars = { exchange: @scope.exchange, page: @scope.page }
		@ExchangeArticle.query(vars).then (response) =>
			@timeout =>
				@scope.loaded = true
				console.log response
				@scope.totalExchangeArticles = response.total if @scope.page is 1
				angular.forEach response.articles, (article) =>
					@scope.exchangeArticles.push article
				@scope.moreToLoad = @scope.totalExchangeArticles > @scope.exchangeArticles.length
				@scope.page += 1
			, timeoutDelay
		, (response) =>
			@refreshPage() if response.status is 401

TheArticle.ControllerModule.controller('ExchangesController', TheArticle.Exchanges)