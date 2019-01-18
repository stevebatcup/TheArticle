class TheArticle.AccountSettings extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$rootElement'
	  '$timeout'
	  '$compile'
	  'EditorsPick'
	]

	init: ->
		@bindEvents()

	bindEvents: ->
		super

TheArticle.ControllerModule.controller('AccountSettingsController', TheArticle.AccountSettings)