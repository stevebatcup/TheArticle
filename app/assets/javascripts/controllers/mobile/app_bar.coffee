class TheArticle.AppBar extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
		'$scope'
		'$rootScope'
		'$http'
		'$element'
		'$interval'
	]

	init: ->
		@setDefaultHttpHeaders()
		@scope.signedIn = !!@element.data('signed-in')
		@scope.notificationBadgeCount = 0
		@getNotificationsBadgeUpdate()
		@bindEvents()

	bindEvents: =>
		if @scope.signedIn
			@interval =>
				@getNotificationsBadgeUpdate()
			, 10000

	getNotificationsBadgeUpdate: =>
		@http.get("/notification-count").then (response) =>
			@scope.notificationBadgeCount = response.data.count

TheArticle.ControllerModule.controller('AppBarController', TheArticle.AppBar)