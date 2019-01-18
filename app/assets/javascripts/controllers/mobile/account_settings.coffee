class TheArticle.AccountSettings extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$rootElement'
	  '$timeout'
	  '$compile'
	]

	init: ->
		@bindEvents()

	bindEvents: ->

TheArticle.ControllerModule.controller('AccountSettingsController', TheArticle.AccountSettings)