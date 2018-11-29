class Mobile extends TheArticle
	constructor: ->
		super()

	bindEvents: =>
		@bindCookieAcceptance()
		@bindSideMenu()
		@bindJoinForm()
		@bindContactForm()
		@bindBlockClicks()
		@bindSearch()
		@bindCarousels()
		@bindSearchFilters()
		@bindFixedNavScrolling() if @isDevelopment()

	bindBlockClicks: =>
		$('.block_click').on 'click', (e) =>
			@blockClick $clicked, e
		super()


	bindSideMenu: =>
		$("#sidebar").mCustomScrollbar
			theme: "minimal"

		$('#dismiss, .overlay, .join_button').on 'click', =>
			$('#sidebar').removeClass('active')
			$('.overlay').removeClass('active')

		$('#sidebarCollapse').on 'click', =>
			$('#search_box').slideUp(200) if $('#search_box').is(':visible')
			$('#sidebar').addClass('active')
			$('.overlay').addClass('active')
			$('.collapse.in').toggleClass('in')
			$('a[aria-expanded=true]').attr('aria-expanded', 'false')
			$('#dismiss, ul', 'nav#sidebar').show()

	bindFixedNavScrolling: =>
		$win = $(window)
		$header = $('header#main_header')
		$headerPosition = Math.round $header.position().top
		$win.on 'scroll', =>
			scrollTop = document.scrollingElement.scrollTop
			if scrollTop  >= $headerPosition
				$('body').addClass('fixed-header')
			else
				$('body').removeClass('fixed-header')

	bindSearch: =>
		$('.search_trigger').on 'click', (e) =>
			e.preventDefault()
			$box = $('#search_box')
			if $box.is(':hidden')
				$box.slideDown(200)
				$box.find('input[name=s]').focus()
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
			, 350

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


window.Mobile = Mobile