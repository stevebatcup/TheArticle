class TheArticle.PageTransitions extends TheArticle.PageController

	listenForBack: =>
		@scope.$on 'page_moving_back', =>
			@backToPage _.last(@scope.pageHistory)

	resetContainerHeight: =>
		@timeout =>
			height = $('.slidepage-page.current').outerHeight() + 120
			$('.slidepage-container').css({ height: height })
		, 100

	resetPages: =>
		$('.slidepage-page').removeClass('current')
					.removeClass('center')
					.removeClass('transition')
					.removeClass('left')
					.addClass('right')
		$('.slidepage-page').first().addClass('center')
					.removeClass('right')
					.addClass('current')
		@rootScope.$broadcast 'page_moved_back', { title: 'Settings', showBack: false }
		@scope.pageHistory = []
		@resetContainerHeight()
		@timeout =>
			$('.slidepage-container').scrollTop(0)
			$(window).scrollTop(0)
		, 300

	forwardToPage: ($event, newPage) =>
		$event.preventDefault() if $event?
		$currentPage = $('[data-page].current')
		$currentPage.removeClass('center').removeClass('current').addClass('left')
		$newPage = $("[data-page=#{newPage}]")
		$newPage.removeClass('right').addClass('center').addClass('current').addClass('transition')
		@scope.pageHistory.push $currentPage.data('page')
		@rootScope.$broadcast 'page_moved_forward', { title: $newPage.data('title') }
		$('.slidepage-container').scrollTop(0)
		$(window).scrollTop(0)
		@resetContainerHeight()

	backToPage: (newPage, $event) =>
		$event.preventDefault() if $event?
		$currentPage = $('[data-page].current')
		$currentPage.removeClass('center').removeClass('current').addClass('right')
		$newPage = $("[data-page=#{newPage}]")
		$newPage.removeClass('left').addClass('center').addClass('current').addClass('transition')
		isTopPage = Number($newPage.data('level')) is 1
		@scope.pageHistory.splice(-1,1)
		@rootScope.$broadcast 'page_moved_back', { title: $newPage.data('title'), showBack: !isTopPage }
		$('.slidepage-container').scrollTop(0)
		$(window).scrollTop(0)
		@resetContainerHeight()