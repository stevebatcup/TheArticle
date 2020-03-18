class TheArticle.Nativo extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
		'$scope'
		'$rootScope'
		'$http'
	]

	init: ->
		@setDefaultHttpHeaders()

TheArticle.ControllerModule.controller('NativoController', TheArticle.Nativo)