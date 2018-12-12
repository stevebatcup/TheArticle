class TheArticle.ProfileWizard extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$rootElement'
	  '$timeout'
	  'EditorsPick'
	]

	init: ->
		console.log "ProfileWizard yay!"

TheArticle.ControllerModule.controller('ProfileWizardController', TheArticle.ProfileWizard)