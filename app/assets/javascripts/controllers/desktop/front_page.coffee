class TheArticle.FrontPage extends TheArticle.mixOf TheArticle.DesktopPageController, TheArticle.Feeds

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$timeout'
	  '$interval'
	  '$compile'
	  '$ngConfirm'
	  '$cookies'
	  'Feed'
		'Comment'
		'Opinion'
		'MyProfile'
	]

	init: ->
		$('footer#main_footer_top, footer#main_footer_bottom').hide()
		@setDefaultHttpHeaders()
		@rootScope.isSignedIn = true
		@bindEvents()
		vars = @getUrlVars()
		@disableBackButton() if 'from_wizard' of vars
		@scope.showPasswordChangedThanks = if 'password_changed' of vars then true else false
		@scope.selectedTab = 'articles'

		@timeout =>
			@alert "It looks like you have already completed the profile wizard!", "Wizard completed" if 'wizard_already_complete' of vars
		, 500

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

		@scope.suggestions = []
		@scope.suggestionsLoaded = false
		@scope.suggestionsCarouselReady = false
		@scope.feeds =
			articles:
				data: []
				page: 1
				firstLoaded: false
				loading: true
				totalItems: 0
				moreToLoad: true
			posts:
				data: []
				page: 1
				firstLoaded: false
				loading: true
				totalItems: 0
				moreToLoad: true
				share_ids: []
			follows:
				data: []
				page: 1
				firstLoaded: false
				loading: true
				totalItems: 0
				moreToLoad: true
		@getFeeds('articles')
		@getSuggestions()

		@scope.myProfile = {}
		@getMyProfile()

		@listenForActions()
		if ($('#flash_notice').length > 0) and (@cookies.get('ok_to_flash'))
			@flash $('#flash_notice').html()
			@cookies.remove('ok_to_flash')

		@scope.followCounts =
			followers: 0
			followings: 0
			connections: 0
		@updateMyFollowCounts()
		@interval =>
			@updateMyFollowCounts()
		, 10000

	bindEvents: =>
		super
		@bindScrollEvent()
		$(document).on 'show.bs.tab', 'a[data-toggle="tab"]', (e) =>
			$hiding = $(e.relatedTarget)
			if $hiding.hasClass('search_trigger')
				@toggleSearch()

		$(document).on 'click', '.other_followers_of_user', (e) =>
			e.preventDefault()
			$span = $(e.currentTarget).parent()
			followedId = $span.data('followed')
			@showAllMyFollowersOfUser(followedId)

		$(document).on 'click', '.other_followers_of_exchange', (e) =>
			e.preventDefault()
			$span = $(e.currentTarget).parent()
			exchangeId = $span.data('exchange')
			@showAllMyFollowersOfExchange(exchangeId)

		$(document).on 'click', '.also_agreed', (e) =>
			e.preventDefault()
			$span = $(e.currentTarget).parent()
			shareId = $span.data('share')
			@showAllShareOpinionators(shareId, 'Agree')

		$(document).on 'click', '.also_disagreed', (e) =>
			e.preventDefault()
			$span = $(e.currentTarget).parent()
			shareId = $span.data('share')
			@showAllShareOpinionators(shareId, 'Disagree')

		$(document).on 'click', '.also_commented', (e) =>
			e.preventDefault()
			$span = $(e.currentTarget).parent()
			shareId = $span.data('share')
			@showAllShareCommenters(shareId)

		if @isTablet()
			$(window).on "orientationchange", (e) =>
				if @scope.selectedTab is 'follows'
					@resetSuggestionsCarousel()
				else
					@scope.suggestionsCarouselReady = false

	selectTab: (section='all') =>
		@scope.selectedTab = section
		if @scope.feeds[section].firstLoaded is false
			@getFeeds(section)

	bindScrollEvent: =>
		$win = $(window)
		$win.on 'scroll', =>
			if (@scope.feeds[@scope.selectedTab].moreToLoad is true) and (!@scope.feeds[@scope.selectedTab].loading)
				scrollTop = $win.scrollTop()
				docHeight = @getDocumentHeight()
				if (scrollTop + $win.height()) >= (docHeight - 700)
					@scope.feeds[@scope.selectedTab].moreToLoad = false
					@loadMore(@scope.selectedTab)

	loadMore: (section='articles') =>
		@scope.feeds[section].page += 1
		@getFeeds(section)

	getFeeds: (section='articles')=>
		@scope.feeds[section].loading = true
		@Feed.query({ page: @scope.feeds[section].page, section: section }).then (response) =>
			angular.forEach response.feedItems, (feed, index) =>
				if section is 'posts'
					if _.contains(@scope.feeds.posts.share_ids, feed.share.id)
						feed.isVisible = false
					else
						@scope.feeds.posts.share_ids.push feed.share.id

				@scope.feeds[section].data.push feed

				if feed.share?
					if feed.share.showComments is true
						@showComments(null, feed, false)
					else if feed.share.showAgrees is true
						@showAgrees(null, feed)
					else if feed.share.showDisagrees is true
						@showDisagrees(null, feed)

			@scope.feeds[section].loading = false
			@scope.feeds[section].firstLoaded = true

			if @scope.feeds[section].page is 1
				@scope.feeds[section].totalItems = response.total
				if (section is 'follows') and (@scope.suggestionsCarouselReady is false)
					@scope.feeds.follows.data.push { type: 'suggestion' }
					@timeout =>
						@setupSuggestionsCarousel()
					, 250

			@scope.feeds[section].moreToLoad = (@scope.feeds[section].totalItems > @scope.feeds[section].data.length)

	getMyProfile: (callback=null) =>
		@MyProfile.get().then (profile) =>
			@scope.myProfile = profile

	openMyProfile: ($event, panel) =>
		$event.preventDefault()
		window.location.href = "/my-profile?panel=#{panel}"

	updateAllSharesWithOpinion: (shareId, action, user) =>
		@updateAllWithOpinion(@scope.feeds.posts.data, shareId, action, user)

	getSuggestions: =>
		@scope.suggestionsLoaded = true
		@http.get('/follow-suggestions').then (response) =>
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

	resetSuggestionsCarousel: =>
		$('.slick-carousel.suggestions').slick('unslick')
		@timeout =>
			@setupSuggestionsCarousel()
		, 350

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