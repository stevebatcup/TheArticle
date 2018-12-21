class TheArticle.Exchanges extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$element'
	  '$timeout'
	  'ExchangeArticle'
	]

	init: ->
		@bindEvents()
		@scope.exchangeArticles =
			page: 1
			items: []
			totalItemCount: 0
			firstLoaded: false
			loading: false
			moreToLoad: true
		@scope.exchange = @element.data('exchange')
		@signedIn = !!@element.data('signed-in')
		if @signedIn
			@setDefaultHttpHeaders()
			@getUserExchanges()
			@scope.userExchangesLoaded = false

	bindEvents: ->
		super
		$('.slick-carousel.articles').first().on 'init', (e) =>
			@getArticles() if @scope.exchange

	getUserExchanges: =>
		@userExchanges = []
		@http.get("/user_exchanges").then (exchanges) =>
			@userExchanges = _.map exchanges.data.exchanges, (e) =>
				e.id
			@scope.userExchangesLoaded = true

	toggleFollowExchange: (exchangeId) =>
		if @inFollwedExchanges(exchangeId)
			@unfollow(exchangeId)
		else
			@follow(exchangeId)

	inFollwedExchanges: (exchangeId) =>
		_.contains @userExchanges, exchangeId

	follow: (exchangeId) =>
		@http.post("/user_exchanges", {id: exchangeId}).then (response) =>
			@userExchanges.push exchangeId

	unfollow: (exchangeId) =>
		@http.delete("/user_exchanges/#{exchangeId}").then (response) =>
			@userExchanges = _.filter @userExchanges, (item) =>
				 item isnt exchangeId

	loadMore: =>
		@getArticles()

	getArticles: =>
		@scope.exchangeArticles.loading = true
		timeoutDelay = if @scope.exchangeArticles.page is 1 then 1200 else 1
		vars = { exchange: @scope.exchange, page: @scope.exchangeArticles.page, perPage: @element.data('per-page') }
		@ExchangeArticle.query(vars).then (response) =>
			@timeout =>
				@scope.exchangeArticles.totalItemCount = response.total if @scope.exchangeArticles.page is 1
				angular.forEach response.articles, (article) =>
					@scope.exchangeArticles.items.push article
				@scope.exchangeArticles.moreToLoad = @scope.exchangeArticles.totalItemCount > @scope.exchangeArticles.items.length
				@scope.exchangeArticles.firstLoaded = true if @scope.exchangeArticles.page is 1
				@scope.exchangeArticles.loading = false
				@scope.exchangeArticles.page += 1
			, timeoutDelay
		, (response) =>
			@refreshPage() if response.status is 401

TheArticle.ControllerModule.controller('ExchangesController', TheArticle.Exchanges)