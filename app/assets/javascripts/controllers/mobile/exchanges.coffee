class TheArticle.Exchanges extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$timeout'
	  '$compile'
	  '$ngConfirm'
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
			@scope.userExchanges =
				ids: []
				page: 1
				perPage: 15
				moreToLoad: false
				totalItems: 0
				loaded: false
			@getUserExchanges()

	bindEvents: ->
		super
		$('.slick-carousel.articles').first().on 'init', (e) =>
			@getArticles() if @scope.exchange

	getUserExchanges: =>
		url = "/user_exchanges?page=#{@scope.userExchanges.page}&per_page=#{@scope.userExchanges.perPage}"
		@http.get(url).then (exchanges) =>
			angular.forEach exchanges.data.exchanges, (exchange) =>
				@scope.userExchanges.ids.push exchange.id
			@scope.userExchanges.totalItems = exchanges.data.total if @scope.userExchanges.page is 1
			@scope.userExchanges.moreToLoad = @scope.userExchanges.totalItems > (@scope.userExchanges.page * @scope.userExchanges.perPage)
			if @scope.userExchanges.moreToLoad is true
				@timeout =>
					@loadMoreExchanges()
				, 500
			else
				@scope.userExchanges.loaded = true

	loadMoreExchanges: =>
		@scope.userExchanges.page += 1
		@getUserExchanges()

	toggleFollowExchange: (exchangeId, $event=null) =>
		$event.preventDefault() if $event?
		if !@signedIn
			@requiresSignIn("follow an exchange")
		else
			if @inFollowedExchanges(exchangeId)
				@unfollowExchange exchangeId, (response) =>
					@scope.userExchanges.ids = _.filter @scope.userExchanges.ids, (item) =>
						item isnt exchangeId
					@flash "You are no longer following the <b>#{response.data.exchange}</b> exchange"
			else
				@followExchange exchangeId, (response) =>
					@scope.userExchanges.ids.push exchangeId
					@flash "You are now following the <b>#{response.data.exchange}</b> exchange"

	inFollowedExchanges: (exchangeId) =>
		_.contains @scope.userExchanges.ids, exchangeId

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