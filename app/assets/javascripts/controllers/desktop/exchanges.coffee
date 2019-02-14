class TheArticle.Exchanges extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$element'
	  '$compile'
	  '$timeout'
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
			@scope.userExchanges = []
			@scope.userExchangesLoaded = false
			@getUserExchanges()

	bindEvents: ->
		super
		$('.slick-carousel.articles').first().on 'init', (e) =>
			@getArticles() if @scope.exchange

	getUserExchanges: =>
		@http.get("/user_exchanges").then (exchanges) =>
			@scope.userExchanges = _.map exchanges.data.exchanges, (e) =>
				e.id
			@scope.userExchangesLoaded = true

	toggleFollowExchange: (exchangeId, $event=null) =>
		$event.preventDefault() if $event?
		if !@signedIn
			@requiresSignIn("follow an exchange")
		else
			if @inFollowedExchanges(exchangeId)
				@unfollow(exchangeId)
			else
				@follow(exchangeId)

	inFollowedExchanges: (exchangeId) =>
		_.contains @scope.userExchanges, exchangeId

	follow: (exchangeId) =>
		@http.post("/user_exchanges", {id: exchangeId}).then (response) =>
			@scope.userExchanges.push exchangeId
			@flash "You are now following the <b>#{response.data.exchange}</b> exchange"

	unfollow: (exchangeId) =>
		@http.delete("/user_exchanges/#{exchangeId}").then (response) =>
			@scope.userExchanges = _.filter @scope.userExchanges, (item) =>
				 item isnt exchangeId
			@flash "You are no longer following the <b>#{response.data.exchange}</b> exchange"

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