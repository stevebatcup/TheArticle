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
		@scope.selectedTab = 'articles'

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
		@getFeeds('posts')
		@getFeeds('follows')
		@getSuggestions()
		@scope.myProfile = {}
		@getMyProfile()

		@listenForActions()
		if ($('#flash_notice').length > 0) and (@cookies.get('ok_to_flash'))
			@flash $('#flash_notice').html()
			@cookies.remove('ok_to_flash')

	bindEvents: =>
		$(document).on 'shown.bs.tab', 'a[data-toggle="tab"]', (e) =>
			@timeout =>
				$(window).scrollTop(0)
			, 50

		$(document).on 'show.bs.tab', 'a[data-toggle="tab"]', (e) =>
			# $(window).scrollTop(170)
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
			if (@scope.feeds[@scope.selectedTab].moreToLoad is true) and (!@scope.feeds[@scope.selectedTab].loading)
				@scope.feeds[@scope.selectedTab].moreToLoad = false
				@loadMore(@scope.selectedTab)

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

	selectTab: (section='all', canClick=false) =>
		if canClick
			@scope.selectedTab = section
			if @scope.feeds[section].firstLoaded is false
				@getFeeds(section)
			if (@scope.suggestionsCarouselReady is false) and (@scope.selectedTab is 'follows')
				@timeout =>
					@setupSuggestionsCarousel()
				, 150
		else
			return false

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
				@scope.feeds.follows.data.push { type: 'suggestion' } if (section is 'follows')

			@scope.feeds[section].moreToLoad = (@scope.feeds[section].totalItems > @scope.feeds[section].data.length)

	getMyProfile: (callback=null) =>
		@MyProfile.get().then (profile) =>
			@scope.myProfile = profile

	updateAllSharesWithOpinion: (shareId, action, user) =>
		@updateAllWithOpinion(@scope.feeds.posts.data, shareId, action, user)

	getSuggestions: =>
		@http.get('/follow-suggestions').then (response) =>
			angular.forEach response.data.suggestions.forYous, (suggestion) =>
				@scope.suggestions.push suggestion
			angular.forEach response.data.suggestions.populars, (suggestion) =>
				@scope.suggestions.push suggestion
			@timeout =>
				@scope.suggestionsLoaded = true
			, 500

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

	toggleFollowUserFromCard: (member) =>
		member.imFollowing = true
		@followUser member.id, =>
			@timeout =>
				@scope.suggestions.forYous = _.filter @scope.suggestions.forYous, (item) =>
					item.id isnt member.id
				@scope.suggestions.populars = _.filter @scope.suggestions.populars, (item) =>
					item.id isnt member.id
			, 750
		, true

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