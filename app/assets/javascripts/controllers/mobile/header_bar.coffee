class TheArticle.HeaderBar extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
		'$scope'
		'$rootScope'
		'$element'
		'$http'
		'$timeout'
		'$interval'
		'$compile'
	]

	init: ->
		@scope.scrollTop = 0
		@scope.scrollCurrentMax = 0
		@scope.myProfile = window.location.pathname is "/my-profile"
		@scope.userProfile = false

		@scope.appPage = false
		@scope.showBackPage = false
		@scope.appPageTitle = ''
		@listen()

		if !@scope.myProfile
			@scope.userProfile = window.location.pathname.indexOf("profile/") > 0

		if !@hasAds()
			@timeout =>
				@bindFixedNavScrolling()
			, 1000

		@scope.signedIn = !!@element.data('signed-in')
		@scope.notificationBadgeCount = 0
		@getNotificationsBadgeUpdate()
		if @scope.signedIn
			@interval =>
				@getNotificationsBadgeUpdate()
			, 120000

	listen: =>
		@scope.$on 'setup_app_page', ($event, data) =>
			$('#member_options').hide()
			@scope.appPage = true
			@scope.showBackPage = false
			@scope.appPageTitle = data.title
			@scope.username = data.username

		@scope.$on 'page_moved_forward', ($event, data) =>
			@scope.showBackPage = true
			@scope.appPageTitle = data.title

		@scope.$on 'page_moved_back', ($event, data) =>
			@scope.showBackPage = data.showBack
			@scope.appPageTitle = data.title

		@scope.$on 'username_updated', ($event, data) =>
			@scope.username = data.username

		@scope.$on 'profile_loaded', ($event, data) =>
			@bindProfileNavScrolling()

	toggleFollowUser: (userId) =>
		if @scope.profileDataForHeader.imFollowing
			@scope.profileDataForHeader.imFollowing = false
			@unfollowUser userId, null
		else
			@scope.profileDataForHeader.imFollowing = true
			@followUser userId, null, false

	backPage: ($event) =>
		$event.preventDefault()
		@rootScope.$broadcast 'page_moving_back'

	openFrontPage: =>
		window.location.href = "/my-home"

	bindProfileNavScrolling: =>
		$win = $(window)
		$navBar = $('section#activity_tabs')
		$navBarPosition = Math.round $navBar.offset().top
		offset = 0
		$win.on 'scroll', =>
			unless $('.header_bar_overlay').is(':visible')
				scrollTop = document.scrollingElement.scrollTop
				dir = if scrollTop < @scope.scrollTop then 'up' else 'down'
				@scope.scrollTop = scrollTop
				if scrollTop  >= ($navBarPosition + offset)
					if dir is 'up'
						if (@scope.scrollCurrentMax - scrollTop) > 140
							$('body').addClass('fixed-header') unless $('body').hasClass('fixed-header')
					else
						@scope.scrollCurrentMax = scrollTop
						$('body').addClass('fixed-profile-nav')
						$navBar.addClass('container')
						$('body').removeClass('fixed-header')
				else
					$('body').removeClass('fixed-profile-nav').removeClass('fixed-header')
					$navBar.removeClass('container')

	bindFixedNavScrolling: =>
		unless $('[data-fixed-profile-nav]').length > 0
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
					@scope.scrollCurrentMax = scrollTop
				else
					if (@scope.scrollCurrentMax - scrollTop) > 140
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

	getNotificationsBadgeUpdate: =>
		@http.get("/notification-count").then (response) =>
			@scope.notificationBadgeCount = response.data.count

TheArticle.ControllerModule.controller('HeaderBarController', TheArticle.HeaderBar)
