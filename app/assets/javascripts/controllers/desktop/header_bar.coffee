class TheArticle.HeaderBar extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
		'$scope'
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
			@getNotifications()
			@timeout =>
				@getNotificationsBadgeUpdate()
			, 2000

	bindEvents: =>
		if !@hasAds()
			@timeout =>
				@bindFixedNavScrolling()
			, 1000

		if @scope.signedIn && !@isDevelopment()
			@interval =>
				@getNotificationsBadgeUpdate()
			, 30000
			@scope.$watch 'notificationBadgeCount', (newVal, oldVal) =>
				if oldVal isnt newVal
					@getNotifications()

	getNotificationsBadgeUpdate: =>
		@http.get("/notification-count").then (response) =>
			@scope.notificationBadgeCount = response.data.count

	getNotifications: =>
		@Notification.query({page: 1, per_page: 12, panel: true}).then (response) =>
			@scope.notifications.data = response.notificationItems
			# console.log @scope.notifications.data
			@scope.notifications.totalItems = response.total if @scope.notifications.page is 1
			# console.log @scope.notifications.totalItems
			@scope.notifications.moreToLoad = @scope.notifications.totalItems > @scope.notifications.data.length
			# console.log @scope.notifications.moreToLoad
			@scope.notifications.loaded = true

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
