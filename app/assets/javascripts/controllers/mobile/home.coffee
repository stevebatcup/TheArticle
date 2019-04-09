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
	  'EditorsPick'
	  'SponsoredPick'
	]

	init: ->
		@bindEvents()
		@scope.editorsPicks =
			page: 1
			items:  []
			totalItemCount: 0
			loading: false
			firstLoaded: false

			moreToLoad: true
		vars = @getUrlVars()
		@goodbye() if 'account_deleted' of vars
		@openSigninForm() if 'sign_in' of vars
		@openSigninForm() if 'forgotten_password' of vars
		@openRegisterForm(null, 'homepage_redirect', 'mobile') if 'register' of vars
		@disableBackButton() if 'signed_out' of vars

	bindEvents: =>
		super
		$('.slick-carousel.articles').first().on 'init', (e) =>
			@getEditorsPicks()

		$('.see_more_articles').on 'click', (e) =>
			$clicked = $(e.currentTarget)
			nextSection = Number($clicked.data('section')) + 1
			$clicked.hide().parent().find("a[data-section=#{nextSection}]").show()

		if $('#mobile_register_interstitial_top').length > 0
			@bindScrollInterstitialEvent()

	bindScrollInterstitialEvent: =>
		pos = $('#mobile_register_interstitial_top').position().top + $('#mobile_register_interstitial_top').outerHeight()
		$win = $(window)
		$win.on 'scroll', =>
			scrollTop = $win.scrollTop()
			if scrollTop >= (pos + 10)
				$('#mobile_register_interstitial_top').remove() if $('#mobile_register_interstitial_top').length > 0

	loadMore: (resource) =>
		resource = "get" + resource.charAt(0).toUpperCase() + resource.slice(1)
		@[resource]()

	getEditorsPicks: =>
		@scope.editorsPicks.loading = true
		timeoutDelay = if @scope.editorsPicks.page is 1 then 2500 else 1
		vars = { tagged: 'editors-picks', page: @scope.editorsPicks.page, perPage: @element.data('per-page') }
		@EditorsPick.query(vars).then (response) =>
			@timeout =>
				@scope.editorsPicks.totalItemCount = response.total if @scope.editorsPicks.page is 1
				angular.forEach response.articles, (article) =>
					@scope.editorsPicks.items.push article
				@scope.editorsPicks.moreToLoad = @scope.editorsPicks.totalItemCount > @scope.editorsPicks.items.length
				@scope.editorsPicks.firstLoaded = true if @scope.editorsPicks.page is 1
				@scope.editorsPicks.loading = false
				@scope.editorsPicks.page += 1
			, timeoutDelay
		, (response) =>
			@refreshPage() if response.status is 401

	goodbye: =>
		@alert "Your account has been deleted.  We are sorry to see you go.", "Account deleted"

TheArticle.ControllerModule.controller('HomeController', TheArticle.Home)