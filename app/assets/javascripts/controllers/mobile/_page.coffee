class TheArticle.MobilePageController extends TheArticle.PageController
	constructor: ->
		super

	bindEvents: =>
		@bindCookieAcceptance()
		@bindSideMenu() if $('mobile_side_menu').length
		@bindContactForm()
		@bindBlockClicks()
		setTimeout @bindCarousels, 800
		@bindSearchFilters()

		$(document).on 'show.bs.modal', =>
			$('html').addClass('with_modal')
			@stopBodyScrolling(true)

		$(document).on 'hide.bs.modal', =>
			$('html').removeClass('with_modal')
			@stopBodyScrolling(false)

		$('#open_feedback_form').on 'click', (e) =>
			@openFeedbackForm(e)

	# bindBlockClicks: =>
	# 	$(document).on 'click', '.block_click', (e) =>
	# 		@blockClick $(e.currentTarget), e
	# 	super

	bindSideMenu: =>
		@rootScope.slideout = new Slideout
			'panel': document.getElementById('panel_for_side_menu')
			'menu': document.getElementById('mobile_side_menu')
			'padding': 256
			'tolerance': 70

		$(document).on 'click', '#sidebarCollapse', (e) =>
			e.preventDefault()
			@rootScope.slideout.toggle()

		$(document).on 'click', '.overlay.show_menu', (e) =>
			e.preventDefault()
			@rootScope.slideout.toggle()

		@rootScope.slideout.on 'beforeopen', (e, l) =>
			$('.overlay').addClass('show_menu').addClass('active')

		@rootScope.slideout.on 'beforeclose', (e, l) =>
			$('.overlay').removeClass('show_menu').removeClass('active')

	bindCarousels: =>
		$(document).on 'init', '.slick-carousel', (e) =>
			window.setTimeout =>
				$(e.currentTarget).find('.inner').addClass('shown')
				$('.cloak').fadeIn('slow').removeClass('cloak')
			, 750

		$('.slick-carousel.articles').slick
			infinite: true
			slidesToShow: 1
			slidesToScroll: 1
			adaptiveHeight: true
			speed: 500
			dots: true
			centerMode: if $(window).width() <= 320 then false else true
			arrows: false

		$('.slick-carousel.exchanges').slick
			infinite: true
			slidesToShow: 1
			slidesToScroll: 1
			adaptiveHeight: true
			speed: 500
			dots: if $(window).width() <= 320 then true else false
			centerMode: if $(window).width() <= 320 then false else true
			arrows: false

		$('.slick-carousel.journalists').slick
			infinite: true
			slidesToShow: if $(window).width() <= 320 then 1 else 2
			slidesToScroll: 1
			adaptiveHeight: true
			speed: 300
			dots: if $(window).width() <= 320 then true else false
			arrows: false
			centerMode: true

	openSharingPanel: ($event=null, mode=null) =>
		$event.preventDefault() if $event?
		if @rootScope.isSignedIn
			if @rootScope.profileDeactivated
				@confirm "You will need to reactivate your profile to share or rate an article", =>
					window.location.href = "/account-settings?reactivate=1"
				, null, "Please reactivate profile", ['Cancel', 'Reactivate']
			else if @rootScope.profileIncomplete
				@confirm "You cannot share or rate this article because you have not yet completed your profile", =>
					window.location.href = "/profile/new"
				, null, "Complete your profile", ['Cancel', 'Complete profile']
			else
				@rootScope.sharingPanelMode = mode if mode?
				tpl = $("#sharingPanel").html().trim()
				$content = @compile(tpl)(@scope)
				$('body').append $content
				$("#sharingPanelModal").modal()
		else
			@requiresSignIn("share or rate an article")

	disableDefaultBehaviour: (e) =>
		# console.log 'disableDefaultBehaviour'
		e.preventDefault()

	stopBodyScrolling: (stop) =>
		if stop
			# console.log 'stopBodyScrolling'
			document.body.addEventListener("touchmove", @disableDefaultBehaviour, false)
		else
			# console.log 'startBodyScrolling'
			document.body.removeEventListener("touchmove", @disableDefaultBehaviour, false)
