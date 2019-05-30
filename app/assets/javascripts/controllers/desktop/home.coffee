class TheArticle.Home extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
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
			$list.scrollLeft(scrolledLeft+40)

		$('.nav-scroller-scroll.prev').on 'click', (e) =>
			e.preventDefault()
			$list = $(e.currentTarget).parent().find('ul')
			scrolledLeft = $list.scrollLeft()
			$list.scrollLeft(scrolledLeft-40)

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
		vars = { exchange: @scope.articles[exchange].slug, page: @scope.articles[exchange].page, per_page: @element.data('per-page'), include_sponsored: 1 }
		@ExchangeArticle.query(vars).then (response) =>
			@timeout =>
				@scope.articles[exchange].totalItemCount = response.total if @scope.articles[exchange].page is 1
				angular.forEach response.articles, (article) =>
					@scope.articles[exchange].items.push article
				@scope.articles[exchange].moreToLoad = @scope.articles[exchange].totalItemCount > @scope.articles[exchange].items.length
				@scope.articles[exchange].firstLoaded = true if @scope.articles[exchange].page is 1
				@scope.articles[exchange].loading = false
				@scope.articles[exchange].page += 1
				console.log @scope.articles[exchange]
			, 350
		, (response) =>
			@refreshPage() if response.status is 401

	# getSponsoredPicks: =>
	# 	@scope.sponsoredPicks.loading = true
	# 	timeoutDelay = 2000
	# 	vars = { sponsored_picks: 1 }
	# 	@SponsoredPick.query(vars).then (response) =>
	# 		@timeout =>
	# 			angular.forEach response.articles, (article) =>
	# 				@scope.sponsoredPicks.items.push article
	# 			@scope.sponsoredPicks.firstLoaded = true
	# 			@scope.sponsoredPicks.loading = false
	# 		, timeoutDelay
	# 	, (response) =>
	# 		@refreshPage() if response.status is 401

	goodbye: =>
		@alert "Your account has been deleted.  We are sorry to see you go.", "Account deleted"

TheArticle.ControllerModule.controller('HomeController', TheArticle.Home)