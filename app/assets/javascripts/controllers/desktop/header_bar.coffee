class TheArticle.HeaderBar extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
		'$scope'
		'$http'
		'$timeout'
		'$compile'
		'$interval'
		'Notification'
	]

	init: ->
		@setDefaultHttpHeaders()
		@scope.notificationBadgeCount = 0
		@scope.notifications =
			data: []
			page: 1
			loaded: false
			totalItems: 0
			moreToLoad: true
		@getNotifications()
		@getNotificationsBadgeUpdate()
		@bindEvents()

	bindEvents: =>
		if @isDevelopment()
			@timeout =>
				@bindFixedNavScrolling()
			, 1000

		@interval =>
			@getNotificationsBadgeUpdate()
		, 10000

		@scope.$watch 'notificationBadgeCount', (newVal, oldVal) =>
			if oldVal isnt newVal
				console.log 'grabbing'
				@getNotifications()

	getNotificationsBadgeUpdate: =>
		@http.get("/notification-count").then (response) =>
			@scope.notificationBadgeCount = response.data.count

	getNotifications: =>
		@Notification.query({page: 1, perPage: 12}).then (response) =>
			angular.forEach response.notificationItems, (notification, index) =>
				@scope.notifications.data.push notification
			# console.log @scope.notifications.data
			@scope.notifications.totalItems = response.total if @scope.notifications.page is 1
			# console.log @scope.notifications.totalItems
			@scope.notifications.moreToLoad = @scope.notifications.totalItems > @scope.notifications.data.length
			# console.log @scope.notifications.moreToLoad
			@scope.notifications.loaded = true

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
