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
		$('footer#main_footer_top').hide()
		@setDefaultHttpHeaders()
		@rootScope.isSignedIn = true
		@bindEvents()
		vars = @getUrlVars()
		@disableBackButton() if 'from_wizard' of vars
		@scope.showPasswordChangedThanks = if 'password_changed' of vars then true else false
		@scope.startTime = @element.data('latest-time')
		@scope.selectedTab = 'articles'
		@scope.tabSets =
			articles: []
			posts: []
			follows: []

		@timeout =>
			@alert "It looks like you have already completed the profile wizard!", "Wizard completed" if 'wizard_already_complete' of vars
		, 500

		@scope.suggestions = []
		@scope.suggestionsLoaded = false
		@scope.suggestionsCarouselReady = false
		@scope.replyingToComment =
			comment: {}
			parentComment: {}
			replyingToReply: false
		@scope.postingComment = false
		@scope.commentPostButton = "Post Comment"
		@scope.commentForSubmission =
			value: ''
		@scope.commentChildLimit = false
		@scope.authActionMessage =
			heading: ''
			msg: ''

		@scope.feeds =
			data: []
			page: 1
			loading: true
			firstLoaded: false
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
			if (@scope.feeds.moreToLoad is true) and (!@scope.feeds.loading)
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

		$(document).on 'click', '#feed.front_page_page .also_agreed', (e) =>
			e.preventDefault()
			$span = $(e.currentTarget).parent()
			shareId = $span.data('share')
			@showAllShareOpinionators(shareId, 'Agree')

		$(document).on 'click', '#feed.front_page_page .also_disagreed', (e) =>
			e.preventDefault()
			$span = $(e.currentTarget).parent()
			shareId = $span.data('share')
			@showAllShareOpinionators(shareId, 'Disagree')

		$(document).on 'click', '#feed.front_page_page .also_commented', (e) =>
			e.preventDefault()
			$span = $(e.currentTarget).parent()
			shareId = $span.data('share')
			@showAllShareCommenters(shareId)

	selectTab: (tab='all') =>
		if @scope.feeds.firstLoaded
			@scope.selectedTab = tab
			if (tab is 'follows') and (@scope.suggestionsCarouselReady is false)
				@setupSuggestionsCarousel()
		else
			return false

	loadMore: =>
		@scope.feeds.page += 1
		@getFeeds()

	getFeeds: =>
		@scope.feeds.loading = true
		@Feed.query({ page: @scope.feeds.page, start_time: @scope.startTime }).then (response) =>
			angular.forEach response.feedItems, (feed, index) =>
				if _.contains(['share', 'rating', 'commentAction', 'opinionAction'], feed.type)
					unless _.contains(@scope.tabSets.posts, feed.share.id)
						@scope.feeds.data.push feed
						@scope.tabSets.posts.push feed.share.id
				else
					@scope.feeds.data.push feed

				if feed.share?
					if feed.share.showComments is true
						@showComments(null, feed, false)
					else if feed.share.showAgrees is true
						@showAgrees(null, feed)
					else if feed.share.showDisagrees is true
						@showDisagrees(null, feed)

			if @scope.feeds.page is 1
				@scope.feeds.totalItems = response.total
				@getSuggestions()
			@scope.startTime = response.nextActivityTime
			@scope.feeds.moreToLoad = (@scope.feeds.totalItems > @scope.feeds.data.length) and (@scope.startTime > 0)
			@scope.feeds.loading = false
			if (@scope.feeds.moreToLoad) and !(@scope.feeds.page % 4 is 0)
				@loadMore()

	getMyProfile: (callback=null) =>
		@MyProfile.get().then (profile) =>
			@scope.myProfile = profile

	updateAllSharesWithOpinion: (shareId, action, user) =>
		@updateAllWithOpinion(@scope.feeds.data, shareId, action, user)

	getSuggestions: =>
		@scope.feeds.data.push { type: 'suggestion' }
		@scope.suggestionsLoaded = true
		@http.get('/follow-suggestions').then (response) =>
			@scope.feeds.firstLoaded = true
			angular.forEach response.data.suggestions.forYous, (suggestion) =>
				@scope.suggestions.push suggestion
			angular.forEach response.data.suggestions.populars, (suggestion) =>
				@scope.suggestions.push suggestion

	setupSuggestionsCarousel: =>
		slidesToShow = if $('#activity-tabs').outerWidth() <= 480 then 1 else 2
		$('.slick-carousel.suggestions').slick
			slidesToShow: slidesToShow
			slidesToScroll: 1
			speed: 300
			dots: false
			centerMode: true
			arrows: true
		@scope.suggestionsCarouselReady = true

	toggleFollowSuggestion: (user, $event) =>
		$event.preventDefault()
		if user.imFollowing
			@unfollowUserFromSuggestion(user)
		else
			@followUserFromSuggestion(user)

	followUserFromSuggestion: (user) =>
		user.imFollowing = true
		@followUser user.id, =>
			# update the old fashioned way
			$('[data-user-id]', '.slick-carousel.suggestions').each (index, slide) =>
				if Number($(slide).data('user-id')) is user.id
					$(slide).find('.follow_btn').addClass("btn-success").removeClass("btn-outline-success").find('span').text("Following")
			@flash "You are now following #{user.username}"
		, true

	unfollowUserFromSuggestion: (user) =>
		user.imFollowing = false
		@unfollowUser user.id, =>
			# update the old fashioned way
			$('[data-user-id]', '.slick-carousel.suggestions').each (index, slide) =>
				if Number($(slide).data('user-id')) is user.id
					$(slide).find('.follow_btn').removeClass("btn-success").addClass("btn-outline-success").find('span').text("Follow")
			@flash "You are no longer following #{user.username}"
		, true

TheArticle.ControllerModule.controller('FrontPageController', TheArticle.FrontPage)