class TheArticle.HeaderBar extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
		'$scope'
		'$rootScope'
		'$http'
		'$element'
		'$timeout'
		'$compile'
		'$interval'
		'Notification'
	]

	init: ->
		@setDefaultHttpHeaders()
		@scope.signedIn = !!@element.data('signed-in')
		@bindEvents()
		if @scope.signedIn
			@scope.notificationBadgeCount = 0
			@scope.notifications =
				data: []
				loaded: false
				totalItems: 0
				moreToLoad: true
			@getNotificationsBadgeUpdate()
			@timeout =>
				@getNotificationsBadgeUpdate()
			, 2000

	bindEvents: =>
		if !@hasAds()
			@timeout =>
				@bindFixedNavScrolling()
			, 1000

		if @scope.signedIn
			@interval =>
				@getNotificationsBadgeUpdate()
			, 10000

	getNotificationsBadgeUpdate: =>
		@http.get("/notification-count").then (response) =>
			@scope.notificationBadgeCount = response.data.count

	bindProfileNavScrolling: =>
		$win = $(window)
		$navBar = $('section#top_bar')
		$navBarPosition = Math.round $navBar.offset().top
		offset = 35
		$win.on 'scroll', =>
			scrollTop = document.scrollingElement.scrollTop
			if scrollTop  >= ($navBarPosition + offset)
				$('body').addClass('fixed-profile-nav')
				$navBar.addClass('container')
			else
				$('body').removeClass('fixed-profile-nav')
				$navBar.removeClass('container')

	bindFixedNavScrolling: =>
		if $('[data-fixed-profile-nav]').length > 0
			@bindProfileNavScrolling()
		else
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
