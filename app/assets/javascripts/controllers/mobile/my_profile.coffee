class TheArticle.MyProfile extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$rootElement'
	  '$timeout'
	  'EditorsPick'
	]

	init: ->

TheArticle.ControllerModule.controller('MyProfileController', TheArticle.MyProfile)