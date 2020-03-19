class TheArticle.SearchResults extends TheArticle.mixOf TheArticle.MobilePageController, TheArticle.Feeds

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$timeout'
	  '$sce'
	  '$compile'
	  '$ngConfirm'
	  '$cookies'
	  'Feed'
		'Comment'
		'Opinion'
		'MyProfile'
	]

	init: ->
		@scope.isSignedIn = !!@element.data('signed-in')
		@scope.selectedTab = 'all'
		@setDefaultHttpHeaders()
		@scope.search =
			allLimit: 6
			query: @element.data('query')
			results:
				empty: true
				loaded: false
				data:
					articles: []
					contributors: []
					profiles: []
					exchanges: []
					posts: []

		@scope.latestArticles = []
		@scope.latestArticlesLoaded = false
		@scope.latestArticlesCarouselReady = false

		@bindEvents()
		@scope.userExchanges =
			ids: []
			page: 1
			perPage: 20
			moreToLoad: false
			totalItems: 0
			loaded: false
		if @scope.isSignedIn
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
			@getUserExchanges()
			@scope.myProfile = {}
			@getMyProfile @getResults
		else
			@getResults()

		@scope.tinymceOptions = @setTinyMceOptions()

	getResults: =>
		url = "/search?query=#{@scope.search.query}"
		url += "&from_tag=1" if !!@element.data('from_tag')
		@http.get(url).then (response) =>
			@scope.search.results.empty = response.data.results.length is 0
			angular.forEach response.data.results, (result) =>
				@scope.search.results.data[result.type].push result
			@scope.search.results.loaded = true
			@scope.latestArticles = response.data.latestArticles
			@scope.latestArticlesLoaded = true

	initLatestArticlesCarousel: =>
		@timeout =>
			$(".slick-carousel.latest_articles").slick
				infinite: true
				slidesToShow: 1
				slidesToScroll: 1
				adaptiveHeight: false
				speed: 300
				dots: false
				centerMode: if $(window).width() <= 360 then false else true
				centerPadding: '60px'
			@scope.latestArticlesCarouselReady = true
		, 150

	getUserExchanges: =>
		url = "/user_exchanges?page=#{@scope.userExchanges.page}&per_page=#{@scope.userExchanges.perPage}"
		@http.get(url).then (exchanges) =>
			angular.forEach exchanges.data.exchanges, (exchange) =>
				@scope.userExchanges.ids.push exchange.id
			@scope.userExchanges.totalItems = exchanges.data.total if @scope.userExchanges.page is 1
			@scope.userExchanges.moreToLoad = @scope.userExchanges.totalItems > (@scope.userExchanges.page * @scope.userExchanges.perPage)
			if @scope.userExchanges.moreToLoad is true
				@timeout =>
					@loadMoreExchanges()
				, 500
			else
				@scope.userExchanges.loaded = true

	loadMoreExchanges: =>
		@scope.userExchanges.page += 1
		@getUserExchanges()

	toggleFollowExchange: (exchangeId, $event=null) =>
		$event.preventDefault() if $event?
		if !@scope.isSignedIn
			@requiresSignIn("follow an exchange", "/search?query=#{@scope.search.query}")
		else
			if @inFollowedExchanges(exchangeId)
				@unfollowExchange(exchangeId)
			else
				@followExchange(exchangeId)

	inFollowedExchanges: (exchangeId) =>
		_.contains @scope.userExchanges.ids, exchangeId

	followExchange: (exchangeId) =>
		@http.post("/user_exchanges", {id: exchangeId}).then (response) =>
			@scope.userExchanges.ids.push exchangeId
			@flash "You are now following the <b>#{response.data.exchange}</b> exchange"

	unfollowExchange: (exchangeId) =>
		@http.delete("/user_exchanges/#{exchangeId}").then (response) =>
			if response.data.status is 'success'
				@scope.userExchanges.ids = _.filter @scope.userExchanges.ids, (item) =>
					 item isnt exchangeId
				@flash "You are no longer following the <b>#{response.data.exchange}</b> exchange"
			else
				@alert response.data.message, "Error unfollowing exchange"

	selectTab: ($event, tab='all') =>
		$event.preventDefault()
		@scope.selectedTab = tab
		$('#feed').scrollTop(0)
		@initLatestArticlesCarousel() if (tab is 'articles') and (@scope.latestArticlesCarouselReady isnt true)

	filterListForTab: (list) =>
		if @scope.selectedTab == 'all'
			list.slice(0, @scope.search.allLimit)
		else
			list

	toggleFollowUserFromCard: (member, $event) =>
		$event.preventDefault()
		if member.imFollowing
			member.imFollowing = false
			@unfollowUser member.id, =>
				@flash "You are no longer following <b>#{member.username}</b>"
		else
			member.imFollowing = true
			@followUser member.id, =>
				@flash "You are now following <b>#{member.username}</b>"
			, false

	getMyProfile: (callback=null) =>
		@MyProfile.get().then (profile) =>
			@scope.myProfile = profile
			callback.call(@) if callback?

	openMyProfile: ($event, panel) =>
		$event.preventDefault()
		window.location.href = "/my-profile?panel=#{panel}"

	updateAllSharesWithOpinion: (shareId, action, user) =>
		@updateAllWithOpinion(@scope.feeds.data, shareId, action, user)

TheArticle.ControllerModule.controller('SearchResultsController', TheArticle.SearchResults)