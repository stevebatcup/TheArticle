class TheArticle.Sidebar extends TheArticle.MobilePageController

	@register window.App
	@$inject: ['$scope', '$timeout', '$compile']

	init: ->

TheArticle.ControllerModule.controller('SidebarController', TheArticle.Sidebar)
