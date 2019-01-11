class TheArticle.FrontPage extends TheArticle.mixOf TheArticle.DesktopPageController, TheArticle.Feeds

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$timeout'
	  'Feed'
		'Comment'
		'Opinion'
	]

	init: ->
		@rootScope.isSignedIn = true
		@bindEvents()
		vars = @getUrlVars()
		@scope.showWelcome = if 'from_wizard' of vars then true else false

		@timeout =>
			@alert "It looks like you have already completed the profile wizard!", "Wizard completed" if 'wizard_already_complete' of vars
		, 500

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

		@scope.feeds =
			data: []
			page: 1
			loaded: false
			totalItems: 0
			moreToLoad: true
		@getFeeds()

	bindEvents: =>
		super
		@bindScrollEvent()
		$(document).on 'show.bs.tab', 'a[data-toggle="tab"]', (e) =>
			$hiding = $(e.relatedTarget)
			if $hiding.hasClass('search_trigger')
				@toggleSearch()

	bindScrollEvent: =>
		$win = $(window)
		$win.on 'scroll', =>
			if @scope.feeds.moreToLoad is true
				scrollTop = $win.scrollTop()
				docHeight = @getDocumentHeight()
				if (scrollTop + $win.height()) >= (docHeight - 600)
					@scope.feeds.moreToLoad = false
					@loadMore()

	loadMore: ($event=null) =>
		$event.preventDefault() if $event
		@scope.feeds.page += 1
		@getFeeds()

	getFeeds: =>
		@Feed.query({page: @scope.feeds.page}).then (response) =>
			angular.forEach response.feedItems, (feed) =>
				@scope.feeds.data.push feed
			# console.log @scope.feeds.data
			@scope.feeds.totalItems = response.total if @scope.feeds.page is 1
			# console.log @scope.feeds.totalItems
			@scope.feeds.moreToLoad = @scope.feeds.totalItems > @scope.feeds.data.length
			# console.log @scope.feeds.moreToLoad
			@scope.feeds.loaded = true


TheArticle.ControllerModule.controller('FrontPageController', TheArticle.FrontPage)