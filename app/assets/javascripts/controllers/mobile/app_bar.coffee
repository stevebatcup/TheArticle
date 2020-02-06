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
		@bindEvents()

	bindEvents: =>
		if @scope.signedIn
			@interval =>
				@getNotificationsBadgeUpdate()
			, 120000


TheArticle.ControllerModule.controller('AppBarController', TheArticle.AppBar)