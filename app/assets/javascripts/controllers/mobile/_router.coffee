class TheArticle.Router extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$timeout'
	  '$interval'
	]

	init: ->
		@setDefaultHttpHeaders()
		@scope.notificationBadgeCount = 0
		@bindEvents()
		@scope.root = @scope
		@timeout =>
			@getNotificationsBadgeUpdate()
		, 2000

		urlVars = @getUrlVars()
		if route = urlVars['route']
			route = route.substring(0, route.indexOf("#")) if route.indexOf("#") > -1
			@openRoute(route) if 'route' of urlVars

	bindEvents: ->
		super
		@scope.$on 'open_followers_tab', =>
			$(window).scrollTop(0)
			@openRoute 'followers'

		@interval =>
			@getNotificationsBadgeUpdate()
		, 7500

	getNotificationsBadgeUpdate: =>
		@http.get("/notification-count").then (response) =>
			@scope.notificationBadgeCount = response.data.count

	openRoute: (route) =>
		switch route
			when 'front' then @openFrontPage()
			when 'myprofile' then @openMyProfile()
			when 'account' then @openAccountSettings()
			when 'following' then @openFollows('following')
			when 'followers' then @openFollows('followers')
			when 'suggestions' then @openFollows('suggestions')
			when 'search' then @openSearch()
			when 'notifications' then @openNotifications()
			when 'messaging' then @openMessaging()
			else @openFrontPage()

	resetAppTabs: =>
		@scope.appPage = false
		@scope.accountSettings = false
		@scope.front_page = false
		@scope.showProfile = false
		@scope.myProfile = false
		@scope.follows = false
		@scope.notifications = false
		@scope.messaging = false
		@scope.slideout.close()

	openFrontPage: =>
		@resetAppTabs()
		@scope.front_page = true
		@timeout =>
			$('#front-page-tab').click()
		, 100

	openMyProfile: =>
		@resetAppTabs()
		@scope.showProfile = true
		@scope.myProfile = true
		@scope.appPage = "My Profile"
		@scope.slideout.close()

	openAccountSettings: =>
		@resetAppTabs()
		@scope.accountSettings = true
		@scope.appPage = "Account settings"
		@scope.slideout.close()

	openFollows: (subTab) =>
		@resetAppTabs()
		@scope.follows = true
		@timeout =>
			$('#follows-tab').click()
			$("#follows-sub-tab-#{subTab}").click()
		, 100

	openNotifications: =>
		@resetAppTabs()
		@scope.notifications = true
		@timeout =>
			$('#notifications-tab').click()
		, 100

	openMessaging: =>
		@resetAppTabs()
		@scope.messaging = true
		@timeout =>
			$('#messaging-tab').click()
		, 100

	openSearch: =>
		@resetAppTabs()
		@scope.search = true
		@timeout =>
			$('#search-tab').click()
		, 100

TheArticle.ControllerModule.controller('RouterController', TheArticle.Router)