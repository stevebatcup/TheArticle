class TheArticle.Home extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$rootElement'
	  '$element'
	  '$timeout'
	  '$compile'
	  '$ngConfirm'
	  'ExchangeArticle'
	]

	init: ->
		@bindEvents()
		$('footer#main_footer_top').hide()
		@initArticleData()

		vars = @getUrlVars()
		if 'sign_in' of vars
			@openSigninForm()
		else if 'forgotten_password' of vars
			@openSigninForm()
		else if 'register' of vars
			@openRegisterForm(null, 'homepage_redirect', 'mobile')
		else if 'account_deleted' of vars
			@goodbye()
		else if 'signed_out' of vars
			@disableBackButton()

	selectTab: (exchange) =>
		@scope.selectedTab = exchange
		@getArticles(exchange)
		# if @scope.articles[exchange].moreToLoad
		# 	$('footer#main_footer_top').hide()
		# else
		# 	$('footer#main_footer_top').show()

	initArticleData: =>
		@scope.articles = {}
		$('.tab-pane').each (index, pane) =>
			exchange = $(pane).data('exchange')
			slug = $(pane).data('exchange-slug')
			@scope.articles[exchange] =
				slug: slug
				page: 1
				items:  []
				articleCount: 0
				totalItemCount: 0
				loading: false
				firstLoaded: false
				moreToLoad: true
		@scope.selectedTab = 'latestArticles'
		@getArticles('latestArticles')

	bindEvents: =>
		super
		if $('#mobile_register_interstitial_top').length > 0
			@bindScrollInterstitialEvent()

	bindScrollingArticles: =>
		@timeout =>
			articleHeight = $('article.post').first().outerHeight()
			$win = $(window)
			offset = 20
			$win.on 'scroll', =>
				section = @scope.articles[@scope.selectedTab]
				if section.moreToLoad is true
					scrollTop = $win.scrollTop()
					docHeight = @getDocumentHeight()
					pageScrollOffset = (articleHeight * 4) + 20
					if (scrollTop + $win.height()) >= (docHeight - pageScrollOffset)
						section.moreToLoad = false
						@loadMore("articles.#{@scope.selectedTab}")
		, 1000

	bindScrollInterstitialEvent: =>
		pos = $('#mobile_register_interstitial_top').position().top + $('#mobile_register_interstitial_top').outerHeight()
		$win = $(window)
		$win.on 'scroll', =>
			scrollTop = $win.scrollTop()
			if scrollTop >= (pos + 10)
				$('#mobile_register_interstitial_top').remove() if $('#mobile_register_interstitial_top').length > 0

	loadMore: (str) =>
		exchange = str.substring(str.indexOf(".")+1)
		@scope.articles[exchange].page += 1
		@getArticles(exchange)

	getArticles: (exchange) =>
		@scope.articles[exchange].loading = true
		vars = { exchange: @scope.articles[exchange].slug, page: @scope.articles[exchange].page, per_page: @element.data('per-page'), include_sponsored: 1 }
		@ExchangeArticle.query(vars).then (response) =>
			@timeout =>
				@scope.articles[exchange].totalItemCount = response.total if @scope.articles[exchange].page is 1
				angular.forEach response.articles, (article) =>
					@scope.articles[exchange].items.push article
					@scope.articles[exchange].articleCount += 1 unless article.isSponsored
				@scope.articles[exchange].moreToLoad = @scope.articles[exchange].totalItemCount > @scope.articles[exchange].articleCount
				@scope.articles[exchange].firstLoaded = true if @scope.articles[exchange].page is 1
				@scope.articles[exchange].loading = false
				@bindScrollingArticles() if (@scope.articles[exchange].page is 1) and (exchange is 'latestArticles')
				# $('footer#main_footer_top').show() if !@scope.articles[exchange].moreToLoad
			, 350
		, (response) =>
			@refreshPage() if response.status is 401

	goodbye: =>
		@alert "Your account has been deleted.  We are sorry to see you go.", "Account deleted"

TheArticle.ControllerModule.controller('HomeController', TheArticle.Home)