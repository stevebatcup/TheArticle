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
		@rootScope.profileDeactivated = !!@element.data('profile-deactivated')
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
		@scope.sections = ['articles', 'posts', 'follows']

		@scope.suggestions = []
		@scope.suggestionsLoaded = false
		@scope.suggestionsCarouselReady = []
		@scope.sponsoredPicksCarouselReady = []
		@scope.trendingExchangesCarouselReady = []
		@scope.latestArticlesCarouselReady = []

		@scope.perPage = 16
		@getSuggestions =>
			@getFeeds('articles')

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
				@resetCarousels()

	selectTab: (section='all', canClick=false) =>
		if canClick
			@scope.selectedTab = section
			if @scope.feeds[section].firstLoaded is false
				@getFeeds(section)

			key = @sectionPageKey(section)
			@initSuggestionsCarousels(section) unless @scope.suggestionsCarouselReady[key] is true
			@initLatestArticlesCarousels(section) unless @scope.latestArticlesCarouselReady[key] is true
			@initSponsoredPicksCarousels(section) unless @scope.sponsoredPicksCarouselReady[key] is true
			@initTrendingExchangesCarousels(section) unless @scope.trendingExchangesCarouselReady[key] is true
		else
			return false

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
		@Feed.query({ page: @scope.feeds[section].page, per_page: @scope.perPage, section: section }).then (response) =>
			angular.forEach response.feedItems, (feed, index) =>
				if section is 'posts'
					if _.contains(@scope.feeds.posts.share_ids, feed.share.id)
						feed.isVisible = false
					else
						@scope.feeds.posts.share_ids.push feed.share.id

				@scope.feeds[section].data.push(feed) unless feed.isVisible is false

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
				if section is 'articles'
					@scope.latestArticles = response.latestArticles
					@scope.sponsoredPicks = response.sponsoredPicks
					@scope.trendingExchanges = response.trendingExchanges
					@scope.userExchanges = response.userExchanges
					@getFeeds('posts')
					@getFeeds('follows')
			feedLength = @getLengthOfFeedWithExtras(section)
			# console.log("feed length for #{section}: #{feedLength}") if console?
			@scope.feeds[section].moreToLoad = (@scope.feeds[section].totalItems > feedLength)

			@buildSuggestionsCarousel(section)
			@buildLatestArticlesCarousels(section)
			@buildSponsoredPicksCarousels(section)
			@buildTrendingExchangesCarousels(section)
			@buildFeaturedSponsoredPost(section)

	getLengthOfFeedWithExtras: (section) =>
		@scope.feeds[section].data.length + (@scope.feeds[section].page * 5)

	buildSuggestionsCarousel: (section) =>
		page = @scope.feeds[section].page
		feedItem = { type: 'suggestion', isVisible: true, page: "#{section}_#{page}" }
		offset = ((page - 1) * @scope.perPage) + 2
		offset += 5 if page > 1
		if @scope.feeds[section].data.length >= offset
			@scope.feeds[section].data.splice(offset, 0, feedItem)
		else
			@scope.feeds[section].data.push feedItem
		@initSuggestionsCarousels(section) if section is 'articles'

	initSuggestionsCarousels: (section) =>
		@timeout =>
			slidesToShow = if $('#activity-tabs').outerWidth() <= 480 then 1 else 2
			key = @sectionPageKey(section)
			$(".slick-carousel.suggestions[data-page=#{key}]", ".section_#{section}").slick
				slidesToShow: slidesToShow
				slidesToScroll: 1
				speed: 300
				dots: false
				centerMode: true
				arrows: true
			@scope.suggestionsCarouselReady[key] = true
		, 100

	buildLatestArticlesCarousels: (section) =>
		page = @scope.feeds[section].page
		feedItem = { type: 'latestArticles', isVisible: true, page: "#{section}_#{page}" }
		offset = ((page - 1) * @scope.perPage) + 6
		offset += 5 if page > 1
		if @scope.feeds[section].data.length >= offset
			@scope.feeds[section].data.splice(offset, 0, feedItem)
		else
			@scope.feeds[section].data.push feedItem
		@initLatestArticlesCarousels(section) if section is 'articles'

	initLatestArticlesCarousels: (section) =>
		@timeout =>
			key = @sectionPageKey(section)
			slidesToShow = if $('#activity-tabs').outerWidth() <= 540 then 1 else 2
			$(".slick-carousel.latest_articles[data-page=#{key}]", ".section_#{section}").slick
				infinite: true
				slidesToShow: slidesToShow
				slidesToScroll: 1
				adaptiveHeight: false
				speed: 300
				dots: false
				centerMode: true,
				centerPadding: '60px'
			@scope.latestArticlesCarouselReady[key] = true
		, 100

	buildSponsoredPicksCarousels: (section) =>
		page = @scope.feeds[section].page
		feedItem = { type: 'sponsoredPicks', isVisible: true, page: "#{section}_#{page}" }
		offset = ((page - 1) * @scope.perPage) + 10
		offset += 5 if page > 1
		if @scope.feeds[section].data.length >= offset
			@scope.feeds[section].data.splice(offset, 0, feedItem)
		else
			@scope.feeds[section].data.push feedItem
		@initSponsoredPicksCarousels(section) if section is 'articles'

	initSponsoredPicksCarousels: (section) =>
		@timeout =>
			key = @sectionPageKey(section)
			slidesToShow = if $('#activity-tabs').outerWidth() <= 540 then 1 else 2
			$(".slick-carousel.sponsored_picks[data-page=#{key}]", ".section_#{section}").slick
				infinite: true
				slidesToShow: slidesToShow
				slidesToScroll: 1
				adaptiveHeight: false
				speed: 300
				dots: false
				centerMode: true,
				centerPadding: '60px'
			@scope.sponsoredPicksCarouselReady[key] = true
		, 100

	buildTrendingExchangesCarousels: (section) =>
		page = @scope.feeds[section].page
		feedItem = { type: 'trendingExchanges', isVisible: true, page: "#{section}_#{page}" }
		offset = ((page - 1) * @scope.perPage) + 14
		offset += 5 if page > 1
		if @scope.feeds[section].data.length >= offset
			@scope.feeds[section].data.splice(offset, 0, feedItem)
		else
			@scope.feeds[section].data.push feedItem
		@initTrendingExchangesCarousels(section) if section is 'articles'

	initTrendingExchangesCarousels: (section) =>
		@timeout =>
			key = @sectionPageKey(section)
			slidesToShow = if $('#activity-tabs').outerWidth() <= 540 then 1 else 2
			$(".slick-carousel.trending_exchanges[data-page=#{key}]", ".section_#{section}").slick
				infinite: true
				slidesToShow: slidesToShow
				slidesToScroll: 1
				adaptiveHeight: false
				speed: 300
				dots: false
				centerMode: true,
				centerPadding: '60px'
			@scope.trendingExchangesCarouselReady[key] = true
		, 100

	buildFeaturedSponsoredPost: (section) =>
		page = @scope.feeds[section].page
		if page > @scope.sponsoredPicks.length
			remainder = (page % @scope.sponsoredPicks.length)
			sPIndex = remainder - 1
		else
			sPIndex = page - 1
		feedItem = { type: 'featuredSponsoredPick', isVisible: true, article: @scope.sponsoredPicks[sPIndex] }
		offset = ((page - 1) * @scope.perPage) + 21
		offset += 5 if page > 1
		if @scope.feeds[section].data.length >= offset
			@scope.feeds[section].data.splice(offset, 0, feedItem)
		else
			@scope.feeds[section].data.push feedItem

	toggleFollowExchange: (exchangeId, $event=null) =>
		$event.preventDefault() if $event?
		if @inFollowedExchanges(exchangeId)
			@unfollowExchange(exchangeId)
		else
			@followExchange(exchangeId)

	inFollowedExchanges: (exchangeId) =>
		_.contains @scope.userExchanges, exchangeId

	followExchange: (exchangeId) =>
		@scope.userExchanges.push exchangeId
		# update the old fashioned way
		$('[data-exchange-id]', '.slick-carousel.exchanges').each (index, slide) =>
			if Number($(slide).data('exchange-id')) is exchangeId
				colour = $(slide).data('colour')
				$(slide).find('a.follow_exchange').removeClass('followed').addClass('followed').html("<i class='fas fa-check text-colour-#{colour}'></i>")
		@http.post("/user_exchanges", {id: exchangeId}).then (response) =>
			@flash "You are now following the <b>#{response.data.exchange}</b> exchange"

	unfollowExchange: (exchangeId) =>
		@http.delete("/user_exchanges/#{exchangeId}").then (response) =>
			if response.data.status is 'success'
				@scope.userExchanges = _.filter @scope.userExchanges, (item) =>
					 item isnt exchangeId
				# update the old fashioned way
				$('[data-exchange-id]', '.slick-carousel.exchanges').each (index, slide) =>
					if Number($(slide).data('exchange-id')) is exchangeId
						$(slide).find('a.follow_exchange').removeClass('followed').html("<i class='fas fa-plus'></i>")
				@flash "You are no longer following the <b>#{response.data.exchange}</b> exchange"
			else
				@alert response.data.message, "Error unfollowing exchange"

	sectionPageKey: (section) =>
		"#{section}_#{@scope.feeds[section].page}"

	getMyProfile: (callback=null) =>
		@MyProfile.get().then (profile) =>
			@scope.myProfile = profile

	openMyProfile: ($event, panel) =>
		$event.preventDefault()
		window.location.href = "/my-profile?panel=#{panel}"

	updateAllSharesWithOpinion: (shareId, action, user) =>
		@updateAllWithOpinion(@scope.feeds.posts.data, shareId, action, user)

	getSuggestions: (callback)=>
		@http.get('/follow-suggestions').then (response) =>
			angular.forEach response.data.suggestions.forYous, (suggestion) =>
				@scope.suggestions.push suggestion
			angular.forEach response.data.suggestions.populars, (suggestion) =>
				@scope.suggestions.push suggestion
			@timeout =>
				@scope.suggestionsLoaded = true
				callback.call(@)
			, 500

	resetCarousels: =>
		window.location.reload()

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