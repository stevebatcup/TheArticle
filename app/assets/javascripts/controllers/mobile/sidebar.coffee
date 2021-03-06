class TheArticle.Sidebar extends TheArticle.MobilePageController

	@register window.App
	@$inject: ['$scope', '$rootScope', '$element', '$http', '$timeout', '$interval', '$compile']

	init: ->
		@setDefaultHttpHeaders()
		@scope.signedIn = !!@element.data('signed-in')

		if @scope.signedIn
			@scope.followCounts =
				followers: 0
				followings: 0
				connections: 0
			@updateMyFollowCounts()
			@interval =>
				@updateMyFollowCounts()
			, 120000

	updateMyFollowCounts: ->
		@http.get("/user_followings?counts=1").then (response) =>
			if response.data? and (response.data.status is 'success')
				@scope.followCounts = response.data.counts

TheArticle.ControllerModule.controller('SidebarController', TheArticle.Sidebar)
