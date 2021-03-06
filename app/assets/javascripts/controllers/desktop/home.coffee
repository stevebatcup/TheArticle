class TheArticle.Home extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$rootElement'
	  '$element'
		'$timeout'
		'$interval'
	  '$compile'
	  '$ngConfirm'
	  'ExchangeArticle'
	]

	init: ->
		@nativeArticleFound = false
		@lastArticleHidden = false
		@bindEvents()
		@initArticleData()

		vars = @getUrlVars()
		deviceType = if @isTablet() then 'tablet' else 'desktop'
		if 'sign_in' of vars
			@openSigninForm()
		else if 'forgotten_password' of vars
			@openSigninForm()
		else if 'register' of vars
			@openRegisterForm(null, 'homepage_redirect', deviceType)
		else if 'account_deleted' of vars
			@goodbye()
		else if 'signed_out' of vars
			@disableBackButton()
		else if @element.data('force-profile-wizard')
			@showProfileWizardModal()
		else if $('#registerInterstitial').length
			@showRegistrationInterstitial()

	selectTab: (tab) =>
		@scope.selectedTab = tab
		@getArticles(tab)

	showProfileWizardModal: =>
		tpl = $("#profileWizard").html().trim()
		$content = @compile(tpl)(@scope)
		$('body').append $content
		$("#profileWizardModal").modal
			backdrop: 'static'
			keyboard: false

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

		$('.nav-scroller-scroll.next').on 'click', (e) =>
			e.preventDefault()
			$list = $(e.currentTarget).parent().find('ul')
			scrolledLeft = $list.scrollLeft()
			$list.scrollLeft(scrolledLeft+85)

		$('.nav-scroller-scroll.prev').on 'click', (e) =>
			e.preventDefault()
			$list = $(e.currentTarget).parent().find('ul')
			scrolledLeft = $list.scrollLeft()
			$list.scrollLeft(scrolledLeft-85)

		$('.see_more_articles').on 'click', (e) =>
			$clicked = $(e.currentTarget)
			nextSection = Number($clicked.data('section')) + 1
			$clicked.hide().parent().find("a[data-section=#{nextSection}]").show()

	loadMore: (str) =>
		exchange = str.substring(str.indexOf(".")+1)
		@scope.articles[exchange].page += 1
		@getArticles(exchange)

	getArticles: (exchange) =>
		@scope.articles[exchange].loading = true
		# perPage = if @scope.articles[exchange].page is 1 then 14 else 15
		perPage = 15
		vars = { exchange: @scope.articles[exchange].slug, page: @scope.articles[exchange].page, per_page: perPage, include_sponsored: 1 }
		@ExchangeArticle.query(vars).then (response) =>
			@showHiddenArticle() if @lastArticleHidden
			@scope.articles[exchange].totalItemCount = response.total if @scope.articles[exchange].page is 1
			angular.forEach response.articles, (article) =>
				@scope.articles[exchange].items.push article
				@scope.articles[exchange].articleCount += 1 unless article.isSponsored
			@scope.articles[exchange].moreToLoad = @scope.articles[exchange].totalItemCount > @scope.articles[exchange].articleCount
			if @scope.articles[exchange].page is 1
				@scope.articles[exchange].firstLoaded = true
				@startNativeArticleTimer()
			else if @scope.articles[exchange].page is 2
				@cancelNativeArticleTimer()
			@scope.articles[exchange].loading = false
			if @nativeArticleFound
				@timeout =>
					@hideLastArticle()
				, 350
		, (response) =>
			@refreshPage() if response.status is 401

	startNativeArticleTimer: =>
		@nativeArticleTimer = @interval =>
			@checkForNativeArticle()
		, 250

	checkForNativeArticle: =>
		console.log 'checkForNativeArticle'
		if angular.element('article.article-listing.ntv_unt').length > 0
			@timeout =>
				console.log 'found'
				@nativeArticleFound = true
				@hideLastArticle()
				@cancelNativeArticleTimer()

	hideLastArticle: =>
		angular.element('article.article-listing:visible').not('.ntv_unt').last().addClass('hidden_by_native_ad').hide()
		@lastArticleHidden = true

	showHiddenArticle: =>
		console.log 'showHiddenArticle'
		console.log angular.element('article.article-listing.hidden_by_native_ad').length
		angular.element('article.article-listing.hidden_by_native_ad').removeClass('hidden_by_native_ad').show()
		@lastArticleHidden = false

	cancelNativeArticleTimer: =>
		@interval.cancel(@nativeArticleTimer)

	goodbye: =>
		@alert "Your account has been deleted.  We are sorry to see you go.", "Account deleted"

TheArticle.ControllerModule.controller('HomeController', TheArticle.Home)