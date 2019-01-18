class TheArticle.ConcernReports extends TheArticle.NGController

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
		@http.defaults.headers.common['Accept'] = 'application/json'
		@http.defaults.headers.common['Content-Type'] = 'application/json'
		@scope.$on 'init_concern_report', (event, data) =>
			@setup(data)

	setup: (data) =>
		@scope.concernReportType = data.type
		@scope.concernReportResource = data.resource
		if @scope.concernReportType == 'profile'
			# console.log 'profile'
			@rootScope.profileForConcernReport =
				id: @scope.concernReportResource.id
				username: @scope.concernReportResource.originalUsername
				imFollowing: false
		else if @scope.concernReportType == 'commentAction'
			# console.log 'commentAction'
			@rootScope.profileForConcernReport =
				id: @scope.concernReportResource.commentAction.user.id
				username: @scope.concernReportResource.user.username
				imFollowing: false
		else if @scope.concernReportType == 'comment'
			# console.log 'comment'
			@rootScope.profileForConcernReport =
				id: @scope.concernReportResource.userId
				username: @scope.concernReportResource.username
				imFollowing: false
		else if @scope.concernReportType == 'post'
			# console.log 'post'
			@rootScope.profileForConcernReport =
				id: @scope.concernReportResource.user.id
				username: @scope.concernReportResource.user.username
				imFollowing: false
		@resetReason()
		# console.log "resource id: #{@scope.concernReportResource.id}"
		# console.log "user id: #{@rootScope.profileForConcernReport.id}"
		@getProfileData @scope.profileForConcernReport.id

	getProfileData: (id) =>
		@Profile.get({id: id}).then (profile) =>
			@rootScope.profileForConcernReport.imFollowing = profile.imFollowing

	resetReason: ($event=null) =>
		$event.preventDefault() if $event
		@scope.reason =
			error: ''
			primarySubmitted: false
			primary: ''
			moreInfo: ''
			secondary: ''
			success: false

	cancelSecondary: ($event) =>
		$event.preventDefault()
		@scope.reason.primarySubmitted = false

	submitProfilePrimary: ($event) =>
		$event.preventDefault()
		@scope.reason.success = false
		@scope.reason.error = ''
		if @scope.reason.primary.length > 0
			if _.contains(['not_interested', 'dont_agree_views', 'hacked', 'offensive_content', 'offensive_photo'], @scope.reason.primary)
				@success()
			else if @scope.reason.primary is 'something_else'
				if @scope.reason.moreInfo.length is 0
					@scope.reason.error = 'Please tell us more about your concern'
				else
					@success()
			else
				@scope.reason.primarySubmitted = true
		else
			@scope.reason.error = 'Please choose an option'

	submitProfileSecondary: ($event) =>
		@scope.reason.error = ''
		$event.preventDefault()
		if @scope.reason.secondary.length is 0
			@scope.reason.error = 'Please choose an option'
		else
			@success()

	submitPostPrimary: ($event) =>
		$event.preventDefault()
		@scope.reason.success = false
		@scope.reason.error = ''
		if @scope.reason.primary.length > 0
			if _.contains(['not_interested', 'dont_agree_post'], @scope.reason.primary)
				@success()
			else if @scope.reason.primary is 'something_else'
				if @scope.reason.moreInfo.length is 0
					@scope.reason.error = 'Please tell us more about your concern'
				else
					@success()
			else
				@scope.reason.primarySubmitted = true
		else
			@scope.reason.error = 'Please choose an option'

	submitPostSecondary: ($event) =>
		@scope.reason.error = ''
		$event.preventDefault()
		if @scope.reason.secondary.length is 0
			@scope.reason.error = 'Please choose an option'
		else
			@success()

	submitCommentPrimary: ($event) =>
		$event.preventDefault()
		@scope.reason.success = false
		@scope.reason.error = ''
		if @scope.reason.primary.length > 0
			if _.contains(['not_interested', 'dont_agree_post'], @scope.reason.primary)
				@success()
			else if @scope.reason.primary is 'something_else'
				if @scope.reason.moreInfo.length is 0
					@scope.reason.error = 'Please tell us more about your concern'
				else
					@success()
			else
				@scope.reason.primarySubmitted = true
		else
			@scope.reason.error = 'Please choose an option'

	submitCommentSecondary: ($event) =>
		$event.preventDefault()
		@scope.reason.error = ''
		if @scope.reason.secondary.length is 0
			@scope.reason.error = 'Please choose an option'
		else
			@success()

	unfollow: ($event) =>
		$event.preventDefault()
		@http.delete("/user_followings/#{@scope.profileForConcernReport.id}").then (response) =>
			@timeout =>
				$('.close_modal', '#concernReportModal').click()
			, 350

	success: =>
		@scope.reason.success = true
		type = if @scope.concernReportType is 'commentAction' then 'comment' else @scope.concernReportType
		new @ConcernReport
			user_id: @scope.profileForConcernReport.id
			via:
				type: type
				id: @scope.concernReportResource.id
			reason:
				primary: @scope.reason.primary
				secondary: @scope.reason.secondary
			more_info: @scope.reason.moreInfo
		.create()

TheArticle.ControllerModule.controller('ConcernReportsController', TheArticle.ConcernReports)