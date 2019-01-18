class TheArticle.Notifications extends TheArticle.mixOf TheArticle.MobilePageController, TheArticle.Feeds

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$timeout'
	  '$compile'
	  '$ngConfirm'
	  'Notification'
	  'Share'
	  'Comment'
	  'Opinion'
	]

	init: ->
		# console.log 'init notifications'
		@detectFlashFromGet()
		@rootScope.isSignedIn = true
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
			perPage: 8
			loaded: false
			totalItems: 0
			moreToLoad: false

		@bindEvents()
		@getNotifications()
		@listenForActions()

	bindEvents: =>
		super
		@scope.$on 'load_more_notifications', =>
			if @scope.notifications.moreToLoad is true
				@scope.notifications.moreToLoad = false
				@loadMore()

	loadMore: =>
		console.log 'loading more notifications'
		@scope.notifications.page += 1
		@getNotifications()

	getNotifications: =>
		@Notification.query({page: @scope.notifications.page, per_page: @scope.notifications.perPage}).then (response) =>
			angular.forEach response.notificationItems, (notification, index) =>
				@scope.notifications.data.push notification
			# console.log @scope.notifications.data
			@scope.notifications.totalItems = response.total if @scope.notifications.page is 1
			# console.log @scope.notifications.totalItems
			@scope.notifications.moreToLoad = @scope.notifications.totalItems > (@scope.notifications.page * @scope.notifications.perPage)
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
		@Share.get({id: notification.shareId}).then (item) =>
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
		@http.put("/notification/#{notification.id}", {is_seen: true}).then (response) =>
			notification.isSeen = true

TheArticle.ControllerModule.controller('NotificationsController', TheArticle.Notifications)