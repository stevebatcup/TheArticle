class TheArticle.Notifications extends TheArticle.mixOf TheArticle.DesktopPageController, TheArticle.Feeds

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
	  'FollowGroup'
	]

	init: ->
		@setDefaultHttpHeaders()
		@rootScope.isSignedIn = true
		@bindEvents()
		vars = @getUrlVars()

		@scope.followGroupForModal = {}
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
			perPage: 12
			loaded: false
			totalItems: 0
			moreToLoad: true
		@getNotifications()
		@listenForActions()

	bindEvents: =>
		super
		@bindScrollEvent() if @element.hasClass('notifications_page')

		$(document).on 'click', '.others_commented', (e) =>
			e.preventDefault()
			$span = $(e.currentTarget).parent()
			notificationId = $span.data('notification')
			@showAllOthersNotificationCommentedOn(notificationId)

		$(document).on 'click', '.also_opinionated', (e) =>
			e.preventDefault()
			$span = $(e.currentTarget).parent()
			notificationId = $span.data('notification')
			@showAllOthersNotificationOpinionated(notificationId)

		$(document).on 'click', '.other_followers_of_user', (e) =>
			e.preventDefault()
			$span = $(e.currentTarget).parent()
			notificationId = $span.data('notification')
			@showAllNotificationFollowers(notificationId)

	bindScrollEvent: =>
		$win = $(window)
		$win.on 'scroll', =>
			if @scope.notifications.moreToLoad is true
				scrollTop = $win.scrollTop()
				docHeight = @getDocumentHeight()
				if (scrollTop + $win.height()) >= (docHeight - 600)
					@scope.notifications.moreToLoad = false
					@loadMore()

	showAllOthersNotificationCommentedOn: (id) =>
		@http.get("/all-notification-comments/#{id}").then (response) =>
			@scope.allCommenters = response.data
			tpl = $("#notificationComments").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#notificationCommentsModal").modal()

	showAllOthersNotificationOpinionated: (id) =>
		@http.get("/all-notification-opinions/#{id}").then (response) =>
			@scope.allOpinionators = response.data
			tpl = $("#notificationOpinions").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#notificationOpinionsModal").modal()

	showAllNotificationFollowers: (id) =>
		@http.get("/all-notification-followers/#{id}").then (response) =>
			@scope.allFollowers = response.data
			tpl = $("#notificationFollowers").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#notificationFollowersModal").modal()

	loadMore: ($event=null) =>
		$event.preventDefault() if $event
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
			if item.share.showComments is true
				@showComments(null, item, false)
			tpl = $("#commentPost").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#commentPostModal").modal()
			$(document).on 'hidden.bs.modal', '#commentPostModal', =>
				$content.remove()

	openOpinionModal: (notification) =>
		@Share.get({id: notification.shareId}).then (item) =>
			@scope.item = item
			tpl = $("#opinionPost").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#opinionPostModal").modal()
			$(document).on 'hidden.bs.modal', '#opinionPostModal', =>
				$content.remove()

	openFollowsModal: (notification) =>
		@FollowGroup.get({id: notification.itemId}).then (followGroup) =>
			@scope.followGroupForModal = followGroup
			tpl = $("#followsList").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#followsListModal").modal()
			$(document).on 'hidden.bs.modal', '#followsListModal', =>
				$content.remove()

	toggleFollowUserFromCard: (member) =>
		if member.imFollowing
			@unfollowUser member.id , =>
				member.imFollowing = false
		else
			@followUser member.id, =>
				member.imFollowing = true
			, false

	callNotificationAction: (notification, $event) =>
		$event.preventDefault
		unless $event.target.tagName is "A" or $event.target.tagName is "B"
			switch notification.type
				when 'comment'
					@openCommentModal notification
				when 'opinion'
					@openOpinionModal notification
				when 'followgroup'
					@openFollowsModal notification
				when 'categorisation'
					path = notification.exchange.path
					window.location.href = path
			if notification.isSeen is false
				@http.put("/notification/#{notification.id}", {is_seen: true}).then (response) =>
					notification.isSeen = true

TheArticle.ControllerModule.controller('NotificationsController', TheArticle.Notifications)