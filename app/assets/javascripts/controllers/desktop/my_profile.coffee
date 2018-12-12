class TheArticle.MyProfile extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$rootElement'
	  '$timeout'
	  'EditorsPick'
	]

	init: ->
		console.log "MyProfile yay!"

TheArticle.ControllerModule.controller('MyProfileController', TheArticle.MyProfile)