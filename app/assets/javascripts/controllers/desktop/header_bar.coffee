class TheArticle.HeaderBar extends TheArticle.DesktopPageController

	@register window.App
	@$inject: ['$scope', '$timeout', '$compile']

	init: ->
		if @isDevelopment()
			@timeout =>
				@bindFixedNavScrolling()
			, 1000

	bindFixedNavScrolling: =>
		$win = $(window)
		$header = $('header#main_header')
		$headerPosition = Math.round $header.offset().top
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

TheArticle.ControllerModule.controller('HeaderBarController', TheArticle.HeaderBar)
