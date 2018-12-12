class TheArticle.MobilePageController extends TheArticle.PageController
	constructor: ->
		super

	bindEvents: =>
		@bindCookieAcceptance()
		@bindSideMenu()
		@bindJoinForm()
		@bindContactForm()
		@bindBlockClicks()
		@bindSearch()
		setTimeout @bindCarousels, 800
		@bindSearchFilters()
		@bindFixedNavScrolling() if @isDevelopment()

	bindBlockClicks: =>
		$('.block_click').on 'click', (e) =>
			@blockClick $(e.currentTarget), e
		super

	bindSideMenu: =>
		if $("#mobile_side_menu").length > 0
			@bindMemberSideMenu()
		else
			# console.log 'bind mCustomScrollbar'
			$("#sidebar").mCustomScrollbar
				theme: "minimal"

			$('#dismiss, .overlay, .join_button').on 'click', =>
				$('#sidebar').removeClass('active')
				$('.overlay').removeClass('active')

			$('#sidebarCollapse').on 'click', (e) =>
				e.preventDefault()
				$('#search_box').slideUp(200) if $('#search_box').is(':visible')
				$('#sidebar').addClass('active')
				$('.overlay').addClass('active')
				$('.collapse.in').toggleClass('in')
				$('a[aria-expanded=true]').attr('aria-expanded', 'false')
				$('#dismiss, ul', 'nav#sidebar').show()

	bindMemberSideMenu: =>
		# console.log 'bindMemberSideMenu'
		@scope.slideout = new Slideout
			'panel': document.getElementById('panel_for_side_menu')
			'menu': document.getElementById('mobile_side_menu')
			'padding': 256
			'tolerance': 70

		$(document).on 'click', '#sidebarCollapse', (e) =>
			e.preventDefault()
			@scope.slideout.toggle()

		$(document).on 'click', '.overlay.show_menu', (e) =>
			e.preventDefault()
			@scope.slideout.toggle()

		@scope.slideout.on 'beforeopen', (e, l) =>
			$('.overlay').addClass('show_menu').addClass('active')

		@scope.slideout.on 'beforeclose', (e, l) =>
			$('.overlay').removeClass('show_menu').removeClass('active')

	bindFixedNavScrolling: =>
		if $('#member_options').length
			@bindAppHeaderFixedScrolling()
		else
			$win = $(window)
			$header = $('header#main_header')
			$headerPosition = Math.round $header.position().top
			$win.on 'scroll', =>
				scrollTop = document.scrollingElement.scrollTop
				if scrollTop >= $headerPosition
					$('body').addClass('fixed-header') unless $('body').hasClass('fixed-header')
				else
					$('body').removeClass('fixed-header')

	bindAppHeaderFixedScrolling: =>
		$win = $(window)
		$nav = $('nav#member_options')
		$navPosition = Math.round $nav.position().top
		scrollPosition = 0
		scrollingDirection = 'down'
		$win.on 'scroll', =>
			scrollTop = document.scrollingElement.scrollTop
			if scrollTop > scrollPosition
				scrollingDirection = 'down'
			else
				scrollingDirection = 'up'
			scrollPosition = scrollTop
			if scrollTop >= $navPosition
				if scrollingDirection is 'down'
					$('body').addClass('fixed-nav') unless $('body').hasClass('fixed-nav')
					$('body').removeClass('fixed-header')
				else
					$('body').addClass('fixed-header') unless $('body').hasClass('fixed-header')
					$('body').removeClass('fixed-nav')
			else
				$('body').removeClass('fixed-header').removeClass('fixed-nav')


	bindSearch: =>
		$('.search_trigger').on 'click', (e) =>
			e.preventDefault()
			@toggleSearch()

	toggleSearch: =>
		$box = $('#search_box')
		if $box.is(':hidden')
			$box.slideDown(200)
			$box.find('input[name=query]').focus()
			$('#ads_top').hide()
			$('.wrapper').addClass('no-scroll')
		else
			$box.slideUp(200)
			$('#ads_top').show()
			$('.wrapper').removeClass('no-scroll')

	bindCarousels: =>
		$('.slick-carousel').on 'init', (e) =>
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