class TheArticle.Notifications extends TheArticle.mixOf TheArticle.MobilePageController, TheArticle.Feeds

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$timeout'
	  '$compile'
	  'Notification'
	  'Comment'
	  'Opinion'
	]

	init: ->
		@rootScope.isSignedIn = true
		@bindEvents()
		vars = @getUrlVars()

		@scope.replyingToComment =
			comment: {}
			parentComment: {}
			replyingToReply: false
		@scope.commentForSubmission =
			value: ''
		@scope.commentChildLimit = false
		@scope.authActionMessage =
			heading: ''
			msg: ''

		@scope.item = {}
		@scope.notifications =
			data: []
			page: 1
			loaded: false
			totalItems: 0
			moreToLoad: true
		@getNotifications()

	bindEvents: =>
		super
		@bindScrollEvent() if @element.hasClass('notifications_page')

	bindScrollEvent: =>
		$win = $(window)
		$win.on 'scroll', =>
			if @scope.notifications.moreToLoad is true
				scrollTop = $win.scrollTop()
				docHeight = @getDocumentHeight()
				if (scrollTop + $win.height()) >= (docHeight - 600)
					@scope.notifications.moreToLoad = false
					@loadMore()

	loadMore: ($event=null) =>
		$event.preventDefault() if $event
		@scope.notifications.page += 1
		@getNotifications()

	getNotifications: =>
		@Notification.query({page: @scope.notifications.page, per_page: 5}).then (response) =>
			angular.forEach response.notificationItems, (notification, index) =>
				@scope.notifications.data.push notification
			# console.log @scope.notifications.data
			@scope.notifications.totalItems = response.total if @scope.notifications.page is 1
			# console.log @scope.notifications.totalItems
			@scope.notifications.moreToLoad = @scope.notifications.totalItems > @scope.notifications.data.length
			# console.log @scope.notifications.moreToLoad
			@scope.notifications.loaded = true

	openCommentModal: (notification) =>
		@Comment.get({id: notification.itemId}).then (item) =>
			@scope.item = item
			tpl = $("#commentPost").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#commentPostModal").modal()

	openOpinionModal: (notification) =>
		@Opinion.get({id: notification.itemId}).then (item) =>
			@scope.item = item
			tpl = $("#opinionPost").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#opinionPostModal").modal()

	openFollowsTab: (notification) =>
		@rootScope.$broadcast 'open_followers_tab'

	callNotificationAction: (notification, $event) =>
		$event.preventDefault
		@scope.item = {}
		switch notification.type
			when 'comment'
				@openCommentModal notification
			when 'opinion'
				@openOpinionModal notification
			when 'follow'
				@openFollowsTab notification
			when 'categorisation'
				path = notification.exchange.path
				window.location.href = path

TheArticle.ControllerModule.controller('NotificationsController', TheArticle.Notifications)