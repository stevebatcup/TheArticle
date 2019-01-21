class TheArticle.PageTransitions extends TheArticle.PageController

	listenForBack: =>
		@scope.$on 'page_moving_back', =>
			@backToPage _.last(@scope.pageHistory)

	resetPages: =>
		$('.slidepage-page').removeClass('current')
					.removeClass('center')
					.removeClass('transition')
					.removeClass('left')
					.addClass('right')
		$('.slidepage-page').first().addClass('center')
					.removeClass('right')
					.addClass('current')

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