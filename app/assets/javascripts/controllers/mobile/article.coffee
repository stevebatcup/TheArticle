class TheArticle.Article extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$timeout'
	  '$compile'
	  '$cookies'
	  '$ngConfirm'
	  'ExchangeArticle'
	]

	init: ->
		@setDefaultHttpHeaders()
		@rootScope.isSignedIn = !!@element.data('signed-in')
		@rootScope.profileDeactivated = !!@element.data('profile-deactivated')
		@rootScope.profileIncomplete = !!@element.data('profile-incomplete')
		@scope.articleId = @element.data('article-id')
		@bindEvents()
		urlVars = @getUrlVars()

		if ($('#flash_notice').length > 0) and (@cookies.get('ok_to_flash'))
			@flash $('#flash_notice').html()
			@cookies.remove('ok_to_flash')

		if $('#more_on_exchange').length > 0
			@scope.exchange = @element.data('exchange-id-for-more')
			@scope.exchangeArticles =
				page: 1
				items: []
				totalItemCount: 0
				firstLoaded: false
				loading: false
				moreToLoad: true
			@getArticlesInSameExchange()

		if $('#registerInterstitial').length > 0
			@rootScope.articleRegisterInterstitialTimeout = @timeout =>
				@showRegistrationInterstitial() unless $('.modal').is(':visible')
			, 30000
		else if $('#donationInterstitial').length > 0
			@donationInterstitialSeen = false
			@bindDonationInterstitialScrollEvent()

	bindEvents: ->
		super
		@scope.$on 'swap_share_panel', (e, data) =>
			$("#sharingPanelModal").modal('hide')
			@timeout =>
				@openSharingPanel(null, data.mode)
				if data.startedComments.length > 0
					@timeout =>
						@rootScope.$broadcast 'copy_started_comments', { comments: data.startedComments }
					, 500
			, 350

	bindDonationInterstitialScrollEvent: =>
		$win = $(window)
		triggerPoint = (Math.ceil $win.height() / 2) + 150
		$win.on 'scroll', =>
			scrollTop = document.scrollingElement.scrollTop
			if (scrollTop >= triggerPoint) && !@donationInterstitialSeen
				@showDonationInterstitial()
				@donationInterstitialSeen = true

	loadMore: =>
		@getArticlesInSameExchange()

	getArticlesInSameExchange: =>
		@scope.exchangeArticles.loading = true
		vars = { exchange: @scope.exchange, page: @scope.exchangeArticles.page, perPage: @element.data('per-page'), exclude_id: @scope.articleId }
		@ExchangeArticle.query(vars).then (response) =>
			@timeout =>
				@scope.exchangeArticles.totalItemCount = response.total if @scope.exchangeArticles.page is 1
				angular.forEach response.articles, (article) =>
					@scope.exchangeArticles.items.push article
				@scope.exchangeArticles.moreToLoad = @scope.exchangeArticles.totalItemCount > @scope.exchangeArticles.items.length
				@scope.exchangeArticles.firstLoaded = true if @scope.exchangeArticles.page is 1
				@scope.exchangeArticles.loading = false
				@scope.exchangeArticles.page += 1
			, 300

	viewRatingHistory: ($event) =>
		$event.preventDefault()
		url = "/ratings-history/#{@scope.articleId}"
		if @rootScope.isSignedIn
			window.location.href = url
		else
			@requiresSignIn("view full article ratings.", url)

TheArticle.ControllerModule.controller('ArticleController', TheArticle.Article)