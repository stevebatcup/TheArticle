class Desktop extends TheArticle
	constructor: ->
		super()
		@reLinePosts() unless @isTablet()

	bindEvents: =>
		@bindCookieAcceptance()
		@bindCarousels()
		@bindSearch()
		@bindJoinForm()
		@bindContactForm()
		@bindListingHovers() unless @isTablet()
		@bindBlockClicks()
		@bindSearchFilters()
		@bindFixedNavScrolling() if @isDevelopment()

		$('#join_form_modal').on 'show.bs.modal', (e) =>
			$('#search_box').slideUp(200) if $('#search_box').is(':visible')

		$('#hidden_editors_picks').on 'shown.bs.collapse', (e) =>
			@reLinePosts() unless @isTablet()

		if $('#sidebar').length
			sideBarHeight = $('#sidebar').outerHeight()
			contentHeight = $('#content_box').outerHeight() + $('#img_box').outerHeight()
			if sideBarHeight > 2300
				$('h2', '#featured_articles_sidebar').show()
				$('[data-index=1]', '#featured_articles_sidebar').show()
				if sideBarHeight > 2700
					$('[data-index=2]', '#featured_articles_sidebar').show()
			else if sideBarHeight - contentHeight >= 400
				$('#featured_articles_content_bar').show()

	reLinePosts: =>
		$('.article-listing.post').each (index, post) =>
			if $(post).is(':visible')
				id = $(post).data('id')
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

	bindSearch: =>
		$('.search_trigger').on 'click', (e) =>
			e.preventDefault()
			$box = $('#search_box')
			if $box.is(':hidden')
				$('#ads_top').slideUp(200)
				$box.slideDown(200)
				$('body, html').scrollTop(0)
				$box.find('input[name=s]').focus()
				$('main#main_content').hide()
			else
				$box.slideUp(200)
				$('#ads_top').slideDown(200)
				$('main#main_content').show()

	bindListingHovers: =>
		$('.hoveraction').on 'mouseover', (e) =>
			$(e.currentTarget).addClass('hovered')
		.on 'mouseout', (e) =>
			$(e.currentTarget).removeClass('hovered')

	bindCarousels: =>
		windowWidith = $(window).width()
		$('.slick-carousel').on 'init', (e) =>
			window.setTimeout =>
				$(e.currentTarget).find('.inner').addClass('shown')
			, 350

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

window.Desktop = Desktop