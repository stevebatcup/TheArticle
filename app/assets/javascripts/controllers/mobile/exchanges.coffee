class TheArticle.Exchanges extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$timeout'
	  '$compile'
	  'ExchangeArticle'
	]

	init: ->
		@signedIn = !!@element.data('signed-in')
		@setDefaultHttpHeaders()

		unless @element.data('carousel-only')
			@scope.exchange = @element.data('exchange')
			@scope.exchangeArticles =
				page: 1
				items: []
				totalItemCount: 0
				firstLoaded: false
				loading: false
				moreToLoad: true
			@bindEvents()

		if @signedIn
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

	toggleFollowExchange: (exchangeId, $event=null) =>
		$event.preventDefault() if $event?
		if !@signedIn
			@requiresSignIn("follow an exchange")
		else
			if @inFollowedExchanges(exchangeId)
				@unfollowExchange exchangeId, (response) =>
					@userExchanges = _.filter @userExchanges, (item) =>
						item isnt exchangeId
					@flash "You are no longer following the <b>#{response.data.exchange}</b> exchange"
			else
				@followExchange exchangeId, (response) =>
					@userExchanges.push exchangeId
					@flash "You are now following the <b>#{response.data.exchange}</b> exchange"

	inFollowedExchanges: (exchangeId) =>
		_.contains @userExchanges, exchangeId

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