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
		@scope.sponsoredPicks =
			items:  []
			loading: false
			firstLoaded: false
		vars = @getUrlVars()
		@openSigninForm() if 'sign_in' of vars
		@openSigninForm() if 'forgotten_password' of vars
		deviceType = if @isTablet() then 'tablet' else 'desktop'
		@openRegisterForm(null, 'homepage_redirect', deviceType) if 'register' of vars
		@goodbye() if 'account_deleted' of vars
		@disableBackButton() if 'signed_out' of vars
		@showProfileWizardModal() if @element.data('force-profile-wizard')
		@showRegistrationInterstitial() if $('#registerInterstitial').length

	showProfileWizardModal: =>
		tpl = $("#profileWizard").html().trim()
		$content = @compile(tpl)(@scope)
		$('body').append $content
		$("#profileWizardModal").modal
			backdrop: 'static'
			keyboard: false

	bindEvents: =>
		super
		$('.slick-carousel.articles').first().on 'init', (e) =>
			@getEditorsPicks() unless $('.listings_editorspicks').length > 0
			@getSponsoredPicks() unless $('.listings_sponsoredpicks').length > 0

		$('.see_more_articles').on 'click', (e) =>
			$clicked = $(e.currentTarget)
			nextSection = Number($clicked.data('section')) + 1
			$clicked.hide().parent().find("a[data-section=#{nextSection}]").show()

	loadMore: (resource) =>
		resource = "get" + resource.charAt(0).toUpperCase() + resource.slice(1)
		@[resource]()

	getEditorsPicks: =>
		@scope.editorsPicks.loading = true
		timeoutDelay = if @scope.editorsPicks.page is 1 then 1500 else 1000
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

	getSponsoredPicks: =>
		@scope.sponsoredPicks.loading = true
		timeoutDelay = 2000
		vars = { sponsored_picks: 1 }
		@SponsoredPick.query(vars).then (response) =>
			@timeout =>
				angular.forEach response.articles, (article) =>
					@scope.sponsoredPicks.items.push article
				@addNativeAdSlot()
				@scope.sponsoredPicks.firstLoaded = true
				@scope.sponsoredPicks.loading = false
			, timeoutDelay
		, (response) =>
			@refreshPage() if response.status is 401

	addNativeAdSlot: =>
		middleIndex = Math.floor(@scope.sponsoredPicks.items.length / 2)
		nativeAd =
			id: 999999
			isNative: true
			isSponsored: true
		@scope.sponsoredPicks.items.splice(middleIndex, 0, nativeAd)

	goodbye: =>
		@alert "Your account has been deleted.  We are sorry to see you go.", "Account deleted"

TheArticle.ControllerModule.controller('HomeController', TheArticle.Home)