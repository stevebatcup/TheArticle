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
		@scope.showBackPage = false
		@timeout =>
			@getNotificationsBadgeUpdate()
		, 2000

		urlVars = @getUrlVars()
		if route = urlVars['route']
			route = route.substring(0, route.indexOf("#")) if route.indexOf("#") > -1
			@openRoute(route) if 'route' of urlVars
		else
			@rootScope.selectedAppTab = 'front-page-tab'

	bindEvents: ->
		super
		@bindScrollEvent()

		@scope.$on 'open_followers_tab', =>
			$(window).scrollTop(0)
			@openRoute 'followers'

		@scope.$on 'page_moved_forward', ($event, data) =>
			@scope.showBackPage = true
			@scope.appPageTitle = data.title

		@scope.$on 'page_moved_back', ($event, data) =>
			@scope.showBackPage = data.showBack
			@scope.appPageTitle = data.title

		@interval =>
			@getNotificationsBadgeUpdate()
		, 30000

	backPage: ($event) =>
		$event.preventDefault()
		@rootScope.$broadcast 'page_moving_back'

	bindScrollEvent: =>
		$win = $(window)
		$win.on 'scroll', =>
			scrollTop = $win.scrollTop()
			docHeight = @getDocumentHeight()
			if (scrollTop + $win.height()) >= (docHeight - 300)
				if @scope.selectedAppTab is 'front-page-tab'
					@rootScope.$broadcast 'load_more_feeds'
				else if @scope.selectedAppTab is 'notifications-tab'
					@rootScope.$broadcast 'load_more_notifications'

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
		@rootScope.selectedAppTab = 'front-page-tab'
		@timeout =>
			$('#front-page-tab').click()
		, 100

	openMyProfile: =>
		@resetAppTabs()
		@scope.showProfile = true
		@scope.myProfile = true
		@scope.appPage = "My Profile"
		@scope.appPageTitle = "My Profile"
		@scope.slideout.close()

	openAccountSettings: (subPage=null) =>
		@resetAppTabs()
		@scope.accountSettings = true
		@scope.appPage = "Account settings"
		@scope.appPageTitle = "Account settings"
		@scope.slideout.close()
		if subPage?
			@rootScope.$broadcast 'account_subpage_selected', { page: subPage }

	openFollows: (subTab) =>
		@resetAppTabs()
		@scope.follows = true
		@rootScope.selectedAppTab = 'follows-tab'
		@timeout =>
			$('#follows-tab').click()
			$("#follows-sub-tab-#{subTab}").click()
		, 100

	openNotifications: =>
		@resetAppTabs()
		@scope.notifications = true
		@rootScope.selectedAppTab = 'notifications-tab'
		@timeout =>
			$('#notifications-tab').click()
		, 100

	openMessaging: =>
		@resetAppTabs()
		@scope.messaging = true
		@rootScope.selectedAppTab = 'messaging-tab'
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