class TheArticle.Notifications extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$rootElement'
	  '$timeout'
	  'EditorsPick'
	]

	init: ->
		console.log "notifications yay!"

TheArticle.ControllerModule.controller('NotificationsController', TheArticle.Notifications)