class TheArticle.DesktopPageController extends TheArticle.PageController
	constructor: ->
		super
		@reLinePosts() unless @isTablet()

	bindEvents: =>
		@bindCookieAcceptance()
		@timeout =>
		 @bindCarousels()
		, 700
		@bindContactForm()
		@bindListingHovers() unless @isTablet()
		@bindBlockClicks()
		@bindSearchFilters()

		$('#hidden_editors_picks').on 'shown.bs.collapse', (e) =>
			@reLinePosts() unless @isTablet()

		if $('#sidebar').length
			sideBarHeight = $('#sidebar').outerHeight()
			contentHeight = $('#content_box').outerHeight() + $('#img_box').outerHeight()
			if sideBarHeight > 2000
				articleCount = Math.floor((sideBarHeight - 2000) / 376)
				$('h2', '#featured_articles_sidebar').show() if articleCount > 0
				for i in [0...articleCount]
					$("[data-index=#{i+1}]", '#featured_articles_sidebar').show()
			else if sideBarHeight - contentHeight >= 400
				$('#featured_articles_content_bar').show()

		$('#open_feedback_form').on 'click', (e) =>
			@openFeedbackForm(e)

		if @isTablet()
			$(window).on "orientationchange", (e) =>
				@resetCarousels()

	reLinePosts: =>
		$('.article-listing.post').each (index, post) =>
			if $(post).is(':visible')
				id = $(post).data('id')
				if id?
					title = document.getElementById("article-post-title-#{id}")
					offsetHeight = title.offsetHeight
					lineHeight = parseInt $(title).css('lineHeight'), 10
					lines = offsetHeight / lineHeight
					if lines >= 4 and !$(post).hasClass('relined')
						$description = $(post).find('.entry-content')
						$description.text @truncateNearestWord($description.text(), 50) + " [...]"
						$(post).addClass('relined')

	isTablet: =>
		$('body').hasClass('tablet')

	bindListingHovers: =>
		$(document).on 'mouseover', '.hoveraction', (e) =>
			$(e.currentTarget).addClass('hovered')
		$(document).on 'mouseout', '.hoveraction', (e) =>
			$(e.currentTarget).removeClass('hovered')

	resetCarousels: =>
		$('.slick-carousel').slick('unslick')
		@timeout =>
			@setupCarousels()
		, 200

	bindCarousels: =>
		$('.slick-carousel').on 'init', (e) =>
			window.setTimeout =>
				$(e.currentTarget).find('.inner').addClass('shown')
				$('.cloak').fadeIn('slow').removeClass('cloak').addClass('was_cloaked')
			, 300

		$('.slick-carousel').on 'destroy', (e) =>
			$(e.currentTarget).find('.inner').removeClass('shown')
			$('.was_cloaked').fadeOut('slow').removeClass('was_cloaked').addClass('cloak')

		@setupCarousels()

	setupCarousels: =>
		windowWidith = $(window).width()
		console.log windowWidith

		$('.slick-carousel.articles').slick
			infinite: true
			slidesToShow: if windowWidith <= 768 then 2 else 3
			slidesToScroll: 1
			adaptiveHeight: true
			speed: 300
			dots: true
			centerMode: true,
			centerPadding: '60px'

		$('.slick-carousel.exchanges').slick
			infinite: true
			slidesToShow: if windowWidith <= 768 then 2 else 3
			slidesToScroll: 1
			adaptiveHeight: true
			speed: 300
			dots: false
			centerMode: true

		if windowWidith <= 768
			journoSlidesToShow = 3
		else if windowWidith > 1024
			journoSlidesToShow =  5
		else
			journoSlidesToShow =  4
		$('.slick-carousel.journalists').slick
			infinite: true
			slidesToShow: journoSlidesToShow
			slidesToScroll: 1
			adaptiveHeight: true
			speed: 300
			dots: true
			arrows: true
			centerMode: true

	bindFixedNavScrolling: =>
		unless $('[data-no-fixed-header]').length > 0
			$win = $(window)
			$header = $('header#main_header')
			if $header.length
				$headerPosition = Math.round $header.position().top
				offset = 20
				$win.on 'scroll', =>
					scrollTop = document.scrollingElement.scrollTop
					if scrollTop  >= $headerPosition
						$('body').addClass('fixed-header')
					else
						$('body').removeClass('fixed-header')

					if scrollTop >= $headerPosition + offset
						$header.addClass('short') unless $header.hasClass('short')
					else
						$header.removeClass('short')

	openSharingPanel: ($event=null, mode=null) =>
		$event.preventDefault() if $event?
		if @rootScope.isSignedIn
			@rootScope.sharingPanelMode = mode if mode?
			tpl = $("#sharingPanel").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#sharingPanelModal").modal()
		else
			@requiresSignIn("share or rate an article")
