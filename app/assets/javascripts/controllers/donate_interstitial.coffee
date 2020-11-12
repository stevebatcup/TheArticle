class TheArticle.DonateInterstitial extends TheArticle.PageController

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

	close: ($event) =>
		$event.preventDefault()
		$('#donationInterstitialModal').modal('hide')
		$('#mobile_donate_interstitial_top').remove()

TheArticle.ControllerModule.controller('DonateInterstitialController', TheArticle.DonateInterstitial)