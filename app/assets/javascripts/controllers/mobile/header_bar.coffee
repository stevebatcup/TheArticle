class TheArticle.HeaderBar extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
		'$scope'
		'$rootScope'
		'$http'
		'$timeout'
		'$compile'
	]

	init: ->
		@scope.myProfile = window.location.pathname is "/my-profile"
		@scope.userProfile = false
		if !@scope.myProfile
			@scope.userProfile = window.location.pathname.indexOf("profile/") > 0

		if @isDevelopment()
			@timeout =>
				@bindFixedNavScrolling()
			, 1000

	bindFixedNavScrolling: =>
		if $('#member_options').length
			@bindAppHeaderFixedScrolling()
		else
			$win = $(window)
			$header = $('header#main_header')
			$headerPosition = Math.round $header.offset().top
			$win.on 'scroll', =>
				scrollTop = document.scrollingElement.scrollTop
				if scrollTop >= $headerPosition
					$('body').addClass('fixed-header') unless $('body').hasClass('fixed-header')
				else
					$('body').removeClass('fixed-header')

	bindAppHeaderFixedScrolling: =>
		$win = $(window)
		$nav = $('nav#member_options')
		$navPosition = Math.round $nav.offset().top
		scrollPosition = 0
		scrollingDirection = 'down'
		$win.on 'scroll', =>
			scrollTop = document.scrollingElement.scrollTop
			if scrollTop > scrollPosition
				scrollingDirection = 'down'
			else
				scrollingDirection = 'up'
			scrollPosition = scrollTop
			if scrollTop >= $navPosition
				if scrollingDirection is 'down'
					$('body').addClass('fixed-nav') unless $('body').hasClass('fixed-nav')
					$('body').removeClass('fixed-header')
				else
					$('body').addClass('fixed-header') unless $('body').hasClass('fixed-header')
					$('body').removeClass('fixed-nav')
			else
				$('body').removeClass('fixed-header').removeClass('fixed-nav')

	editProfile: =>
		@rootScope.$broadcast('edit_profile')

	editProfilePhoto: =>
		@rootScope.$broadcast('edit_profile_photo')

	editCoverPhoto: =>
		@rootScope.$broadcast('edit_cover_photo')

	reportProfile: ($event, profile) =>
		$event.preventDefault()
		@rootScope.$broadcast 'report_profile', { profile: profile }

	mute: ($event, userId, username) =>
		$event.preventDefault()
		@rootScope.$broadcast 'mute', { userId: userId, username: username }

	unmute: ($event, userId, username) =>
		$event.preventDefault()
		@rootScope.$broadcast 'unmute', { userId: userId, username: username }

	block: ($event, userId, username) =>
		$event.preventDefault()
		@rootScope.$broadcast 'block', { userId: userId, username: username }

	unblock: ($event, userId, username) =>
		$event.preventDefault()
		@rootScope.$broadcast 'unblock', { userId: userId, username: username }



TheArticle.ControllerModule.controller('HeaderBarController', TheArticle.HeaderBar)
