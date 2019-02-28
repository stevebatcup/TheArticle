class TheArticle.FrontPage extends TheArticle.mixOf TheArticle.MobilePageController, TheArticle.Feeds

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
	  'Feed'
		'Comment'
		'Opinion'
		'MyProfile'
	]

	init: ->
		@setDefaultHttpHeaders()
		@rootScope.isSignedIn = true
		@bindEvents()
		vars = @getUrlVars()
		@disableBackButton() if 'from_wizard' of vars
		@scope.showWelcome = false
		@scope.showPasswordChangedThanks = if 'password_changed' of vars then true else false

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

		@scope.myProfile = {}
		@getMyProfile()

		@listenForActions()
		if ($('#flash_notice').length > 0) and (@cookies.get('ok_to_flash'))
			@flash $('#flash_notice').html()
			@cookies.remove('ok_to_flash')

	bindEvents: =>
		$(document).on 'show.bs.tab', 'a[data-toggle="tab"]', (e) =>
			$(window).scrollTop(0)
			$showing = $(e.target)
			$hiding = $(e.relatedTarget)
			@rootScope.selectedAppTab = $showing.attr('id')

			if $hiding.attr('id') is 'search-tab' or $showing.attr('id') is 'search-tab'
				@rootScope.$broadcast('search-tab-clicked')

			if $showing.attr('id') is 'notifications-tab'
				@scope.$apply =>
					@scope.root.notifications = true
			else
				@scope.$apply =>
					@scope.root.notifications = false
				true

		@scope.$on 'load_more_feeds', =>
			if @scope.feeds.moreToLoad is true
				@scope.feeds.moreToLoad = false
				@loadMore()

		$(document).on 'click', '#feed.front_page_page .other_followers_of_user', (e) =>
			e.preventDefault()
			$span = $(e.currentTarget).parent()
			followedId = $span.data('followed')
			@showAllMyFollowersOfUser(followedId)

		$(document).on 'click', '#feed.front_page_page .other_followers_of_exchange', (e) =>
			e.preventDefault()
			$span = $(e.currentTarget).parent()
			exchangeId = $span.data('exchange')
			@showAllMyFollowersOfExchange(exchangeId)

		$(document).on 'click', '#feed.front_page_page .also_opinionated', (e) =>
			e.preventDefault()
			$span = $(e.currentTarget).parent()
			shareId = $span.data('share')
			@showAllShareOpinionators(shareId)

		$(document).on 'click', '#feed.front_page_page .also_commented', (e) =>
			e.preventDefault()
			$span = $(e.currentTarget).parent()
			shareId = $span.data('share')
			@showAllShareCommenters(shareId)

	loadMore: =>
		console.log 'loading more feeds'
		@scope.feeds.page += 1
		@getFeeds()

	getFeeds: =>
		@Feed.query({page: @scope.feeds.page}).then (response) =>
			angular.forEach response.feedItems, (feed, index) =>
				@scope.feeds.data.push feed
				if feed.share?
					if feed.share.showComments is true
						@showComments(null, feed, false)
					else if feed.share.showAgrees is true
						@showAgrees(null, feed)
					else if feed.share.showDisagrees is true
						@showDisagrees(null, feed)
				if response.suggestions.length > 0
					if (index is 1)
						@scope.feeds.data.push response.suggestions[0]
					else if (index is 4)
						@scope.feeds.data.push response.suggestions[1]
			# console.log @scope.feeds.data
			@scope.feeds.totalItems = response.total if @scope.feeds.page is 1
			# console.log @scope.feeds.totalItems
			@scope.feeds.moreToLoad = @scope.feeds.totalItems > @scope.feeds.data.length
			# console.log @scope.feeds.moreToLoad
			@scope.feeds.loaded = true

	getMyProfile: (callback=null) =>
		@MyProfile.get().then (profile) =>
			@scope.myProfile = profile

	updateAllSharesWithOpinion: (shareId, action, user) =>
		@updateAllWithOpinion(@scope.feeds.data, shareId, action, user)

TheArticle.ControllerModule.controller('FrontPageController', TheArticle.FrontPage)