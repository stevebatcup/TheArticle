class TheArticle.Sidebar extends TheArticle.MobilePageController

	@register window.App
	@$inject: ['$scope', '$rootScope', '$http', '$timeout', '$interval', '$compile']

	init: ->
		@scope.followCounts =
			followers: 0
			followings: 0
			connections: 0
		@updateMyFollowCounts()
		@interval =>
			@updateMyFollowCounts()
		, 10000

	updateMyFollowCounts: ->
		@http.get("/user_followings?counts=1").then (response) =>
			@scope.followCounts = response.data.counts

TheArticle.ControllerModule.controller('SidebarController', TheArticle.Sidebar)
