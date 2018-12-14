class TheArticle.HeaderBar extends TheArticle.MobilePageController

	@register window.App
	@$inject: ['$scope', '$timeout']

	init: ->
		console.log "HeaderBar"
		if @isDevelopment()
			@timeout =>
				@bindFixedNavScrolling()
			, 1000

	bindFixedNavScrolling: =>
		if $('#member_options').length
			@bindAppHeaderFixedScrolling()
		else
			$win = $(window)
			$header = $('header#main_header')
			$headerPosition = Math.round $header.offset().top
			# console.log $headerPosition
			$win.on 'scroll', =>
				scrollTop = document.scrollingElement.scrollTop
				if scrollTop >= $headerPosition
					$('body').addClass('fixed-header') unless $('body').hasClass('fixed-header')
				else
					$('body').removeClass('fixed-header')

	bindAppHeaderFixedScrolling: =>
		# console.log 'bindAppHeaderFixedScrolling'
		$win = $(window)
		$nav = $('nav#member_options')
		$navPosition = Math.round $nav.offset().top
		# console.log $navPosition
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

TheArticle.ControllerModule.controller('HeaderBarController', TheArticle.HeaderBar)
