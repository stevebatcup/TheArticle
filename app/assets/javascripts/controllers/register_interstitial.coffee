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
		$('#mobile_register_interstitial_top').remove()
		gtag('event', 'registration_interstitial_click', { 'decision': 'no_thanks' }) if gtag?

	register: ($event, deviceType='mobile') =>
		$event.preventDefault()
		$('#registerInterstitialModal').modal('hide')
		@setReturnLocation window.location.pathname
		gtag('event', 'registration_interstitial_click', { 'decision': 'register' }) if gtag?
		@openRegisterForm($event, 'interstitial', deviceType)

TheArticle.ControllerModule.controller('RegisterInterstitialController', TheArticle.RegisterInterstitial)