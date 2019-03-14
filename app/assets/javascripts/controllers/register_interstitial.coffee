class TheArticle.RegisterInterstitial extends TheArticle.PageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$timeout'
	  '$compile'
	  'Comment'
	  'Opinion'
	  'Profile'
	  'ConcernReport'
	]

	init: ->

	noThanks: ($event) =>
		$event.preventDefault()
		$('#registerInterstitialModal').modal('hide')

	register: ($event) =>
		$event.preventDefault()
		$('#registerInterstitialModal').modal('hide')
		@openRegisterForm($event)

TheArticle.ControllerModule.controller('RegisterInterstitialController', TheArticle.RegisterInterstitial)