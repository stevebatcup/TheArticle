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
	  '$cookies'
	  '$sce'
	  'Notification'
	  'Share'
	  'Comment'
	  'Opinion'
	  'MyProfile'
	]

	init: ->
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
		@scope.myProfile = {}
		@getMyProfile()

		@scope.tinymceOptions = @setTinyMceOptions()

	bindScrollEvent: =>
		$win = $(window)
		$win.on 'scroll', =>
			scrollTop = $win.scrollTop()
			docHeight = @getDocumentHeight()
			if (scrollTop + $win.height()) >= (docHeight - 320)
				if @scope.notifications.moreToLoad is true
					@scope.notifications.moreToLoad = false
					@loadMore()

	bindEvents: =>
		super
		@bindScrollEvent()

		# @scope.$on 'load_more_notifications', =>
		# 	if @scope.notifications.moreToLoad is true
		# 		@scope.notifications.moreToLoad = false
		# 		@loadMore()

		$(document).on 'click', '#feed.notifications_page .others_commented', (e) =>
			e.preventDefault()
			$span = $(e.currentTarget).parent()
			notificationId = $span.data('notification')
			@showAllOthersNotificationCommentedOn(notificationId)

		$(document).on 'click', '#feed.notifications_page .also_agreed', (e) =>
			e.preventDefault()
			$span = $(e.currentTarget).parent()
			notificationId = $span.data('notification')
			@showAllOthersNotificationOpinionated(notificationId, 'Agree')

		$(document).on 'click', '#feed.notifications_page .also_disagreed', (e) =>
			e.preventDefault()
			$span = $(e.currentTarget).parent()
			notificationId = $span.data('notification')
			@showAllOthersNotificationOpinionated(notificationId, 'Disagree')

		$(document).on 'click', '#feed.notifications_page .other_followers_of_user', (e) =>
			e.preventDefault()
			$span = $(e.currentTarget).parent()
			notificationId = $span.data('notification')
			@showAllNotificationFollowers(notificationId)

		$(document).on 'click', ".mentioned_user", (e) =>
			$clicked = $(e.currentTarget)
			userId = $clicked.data('user')
			window.location.href = "/profile-by-id/#{userId}"

	showAllOthersNotificationCommentedOn: (id) =>
		@http.get("/all-notification-comments/#{id}").then (response) =>
			@scope.allCommenters = response.data
			tpl = $("#notificationComments").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#notificationCommentsModal").modal()

	showAllOthersNotificationOpinionated: (id, decision) =>
		@http.get("/all-notification-opinions/#{id}?decision=#{decision.toLowerCase()}").then (response) =>
			@scope.allOpinionators = response.data
			@scope.allOpinionatorDescision = decision
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

	loadMore: =>
		@scope.notifications.page += 1
		@getNotifications()

	getNotifications: =>
		@Notification.query({page: @scope.notifications.page, per_page: @scope.notifications.perPage}).then (response) =>
			angular.forEach response.notificationItems, (notification, index) =>
				@scope.notifications.data.push notification
			@scope.notifications.totalItems = response.total if @scope.notifications.page is 1
			@scope.notifications.moreToLoad = @scope.notifications.totalItems > (@scope.notifications.page * @scope.notifications.perPage)
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

	openShareModal: (share_id) =>
		@Share.get({id: share_id}).then (item) =>
			@scope.item = item
			tpl = $("#shareBox").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#shareBoxModal").modal()
			$(document).on 'hidden.bs.modal', '#shareBoxModal', =>
				$content.remove()

	openFollowsTab: (notification) =>
		@rootScope.$broadcast 'open_followers_tab'

	callNotificationAction: (notification, $event) =>
		$event.preventDefault
		unless $event.target.tagName is "A" or $event.target.tagName is "B"
			switch notification.type
				when 'comment','commentmentioner'
					@openCommentModal notification
				when 'opinion'
					@openOpinionModal notification
				when 'follow'
					window.location.href = "/user_followings?tab=followers"
				when 'categorisation'
					path = notification.article.path
					window.location.href = path
				when 'mentioner'
					@openShareModal notification.shareId
			@http.put("/notification/#{notification.id}", {is_seen: true}).then (response) =>
				notification.isSeen = true

	getMyProfile: (callback=null) =>
		@MyProfile.get().then (profile) =>
			@scope.myProfile = profile

	openMyProfile: ($event, panel) =>
		$event.preventDefault()
		window.location.href = "/my-profile?panel=#{panel}"

TheArticle.ControllerModule.controller('NotificationsController', TheArticle.Notifications)