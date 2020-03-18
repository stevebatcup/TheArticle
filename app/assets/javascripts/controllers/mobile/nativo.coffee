class TheArticle.Nativo extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
		'$scope'
		'$rootScope'
		'$http'
		'$timeout'
	]

	init: ->
		@setDefaultHttpHeaders()
		@bindEvents()

	bindEvents: ->
		super

TheArticle.ControllerModule.controller('NativoController', TheArticle.Nativo)