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
	  '$sce'
	  'Feed'
		'Comment'
		'Opinion'
		'MyProfile'
	]

	init: ->
		$('footer#main_footer_top').hide()
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
				itemsLoaded: 0
				totalItems: 0
				moreToLoad: true
			posts:
				data: []
				page: 1
				firstLoaded: false
				loading: true
				itemsLoaded: 0
				totalItems: 0
				moreToLoad: true
				share_ids: []
			follows:
				data: []
				page: 1
				firstLoaded: false
				loading: true
				itemsLoaded: 0
				totalItems: 0
				moreToLoad: true
		@scope.sections = ['articles', 'posts', 'follows']

		@scope.suggestions = []
		@scope.suggestionsLoaded = false
		@scope.suggestionsCarouselReady = {}
		@scope.sponsoredPicksCarouselReady = {}
		@scope.trendingExchangesCarouselReady = {}
		@scope.latestArticlesCarouselReady = {}

		@scope.perPage = 16
		@getSuggestions =>
			@getFeeds('articles')

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

			key = @sectionPageKey(section)
			@initSuggestionsCarousels(section) unless @scope.suggestionsCarouselReady[key] is true
			@initLatestArticlesCarousels(section) unless @scope.latestArticlesCarouselReady[key] is true
			@initSponsoredPicksCarousels(section) unless @scope.sponsoredPicksCarouselReady[key] is true
			@initTrendingExchangesCarousels(section) unless @scope.trendingExchangesCarouselReady[key] is true
		else
			return false

	loadMore: (section='articles') =>
		@scope.feeds[section].page += 1
		@getFeeds(section)

	getFeeds: (section='articles', autoGet=false)=>
		@scope.feeds[section].loading = true
		@Feed.query({ page: @scope.feeds[section].page, per_page: @scope.perPage, section: section }).then (response) =>
			angular.forEach response.feedItems, (feed, index) =>
				if section is 'posts'
					if _.contains(@scope.feeds.posts.share_ids, feed.share.id)
						feed.isVisible = false
					else
						@scope.feeds.posts.share_ids.push feed.share.id

				unless feed.isVisible is false
					@scope.feeds[section].data.push(feed)
					@scope.feeds[section].itemsLoaded += 1

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
					@getFeeds('posts', true) unless @rootScope.profileDeactivated
				else if section is 'posts'
					@getFeeds('follows', true) unless @rootScope.profileDeactivated

			@scope.feeds[section].moreToLoad = (@scope.feeds[section].totalItems > @scope.feeds[section].itemsLoaded)

			@buildSuggestionsCarousel(section, autoGet)
			@buildLatestArticlesCarousels(section, autoGet)
			@buildSponsoredPicksCarousels(section, autoGet)
			@buildTrendingExchangesCarousels(section, autoGet)
			@buildFeaturedSponsoredPost(section, autoGet)

	buildSuggestionsCarousel: (section, autoGet=false) =>
		page = @scope.feeds[section].page
		feedItem = { type: 'suggestion', isVisible: true, page: "#{section}_#{page}" }
		offset = ((page - 1) * @scope.perPage) + 2
		offset += 5 if page > 1
		if @scope.feeds[section].data.length >= offset
			@scope.feeds[section].data.splice(offset, 0, feedItem)
		else
			@scope.feeds[section].data.push feedItem
		key = @sectionPageKey(section)
		@initSuggestionsCarousels(section) unless (@scope.suggestionsCarouselReady[key] is true) or (autoGet)

	initSuggestionsCarousels: (section) =>
		@timeout =>
			key = @sectionPageKey(section)
			slideCount = $('.slick-carousel-item', ".section_#{section} .slick-carousel.suggestions[data-page=#{key}]").length
			if slideCount < 3
				initialSlide = 0
			else
				initialSlide = Math.ceil(slideCount / 2) - 1
			$(".slick-carousel.suggestions[data-page=#{key}]", ".section_#{section}").slick
				infinite: false
				slidesToShow: 1
				slidesToScroll: 1
				speed: 300
				dots: false
				centerMode: true
				initialSlide: initialSlide
				arrows: true
			@scope.suggestionsCarouselReady[key] = true
		, 100

	buildLatestArticlesCarousels: (section, autoGet=false) =>
		page = @scope.feeds[section].page
		feedItem = { type: 'latestArticles', isVisible: true, page: "#{section}_#{page}" }
		offset = ((page - 1) * @scope.perPage) + 6
		offset += 5 if page > 1
		if @scope.feeds[section].data.length >= offset
			@scope.feeds[section].data.splice(offset, 0, feedItem)
		else
			@scope.feeds[section].data.push feedItem
		key = @sectionPageKey(section)
		@initLatestArticlesCarousels(section) unless (@scope.latestArticlesCarouselReady[key] is true) or (autoGet)

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
				centerMode: if $(window).width() <= 320 then false else true
				centerPadding: '60px'
			@scope.latestArticlesCarouselReady[key] = true
		, 100

	buildSponsoredPicksCarousels: (section, autoGet=false) =>
		page = @scope.feeds[section].page
		feedItem = { type: 'sponsoredPicks', isVisible: true, page: "#{section}_#{page}" }
		offset = ((page - 1) * @scope.perPage) + 10
		offset += 5 if page > 1
		if @scope.feeds[section].data.length >= offset
			@scope.feeds[section].data.splice(offset, 0, feedItem)
		else
			@scope.feeds[section].data.push feedItem
		key = @sectionPageKey(section)
		@initSponsoredPicksCarousels(section)  unless (@scope.sponsoredPicksCarouselReady[key] is true) or (autoGet)

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
				centerMode: if $(window).width() <= 320 then false else true
				centerPadding: '60px'
			@scope.sponsoredPicksCarouselReady[key] = true
		, 100

	buildTrendingExchangesCarousels: (section, autoGet=false) =>
		page = @scope.feeds[section].page
		feedItem = { type: 'trendingExchanges', isVisible: true, page: "#{section}_#{page}" }
		offset = ((page - 1) * @scope.perPage) + 14
		offset += 5 if page > 1
		if @scope.feeds[section].data.length >= offset
			@scope.feeds[section].data.splice(offset, 0, feedItem)
		else
			@scope.feeds[section].data.push feedItem
		key = @sectionPageKey(section)
		@initTrendingExchangesCarousels(section) unless (@scope.trendingExchangesCarouselReady[key] is true) or (autoGet)

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
				centerMode: if $(window).width() <= 320 then false else true
				centerPadding: '60px'
			@scope.trendingExchangesCarouselReady[key] = true
		, 100

	buildFeaturedSponsoredPost: (section) =>
		page = @scope.feeds[section].page
		if page > @scope.sponsoredPicks.length
			remainder = (page % @scope.sponsoredPicks.length)
			sPIndex = remainder
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

	updateAllSharesWithOpinion: (shareId, action, user) =>
		@updateAllWithOpinion(@scope.feeds.posts.data, shareId, action, user)

	getSuggestions: (callback)=>
		@http.get('/follow-suggestions').then (response) =>
			if response.data.suggestions.populars.length is 0
				list = response.data.suggestions.forYous
			else if response.data.suggestions.populars.length < 16
				list = response.data.suggestions.populars.concat(response.data.suggestions.forYous)
			else
				list = response.data.suggestions.populars
			@scope.suggestions = list.slice(0, 16)

			@timeout =>
				@scope.suggestionsLoaded = true
				callback.call(@)
			, 500

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

	ignoreSuggestion: (member, $event) =>
		$event.preventDefault()
		@ignoreSuggestedMember member.id, =>
			@timeout =>
				$carousels = $(".slick-carousel.suggestions")
				slideIndex = $($event.currentTarget).closest('[data-slick-index]').data('slick-index')
				$carousels.each (cIndex, carousel) =>
					$carousel = $(carousel)
					section = $carousel.closest('[data-section]').data('section')
					if $carousel.find('.slick-track').length
						$carousel.slick('slickRemove', slideIndex)
						# reindex
						indx = 0
						$carousel.find(".slick-carousel-item").each (t, v) =>
							$(v).attr("data-slick-index", indx)
							indx++
						unless $carousel.is(':visible')
							$carousel.slick('unslick')
							_.each @scope.suggestionsCarouselReady, (bool, scrKey) =>
								if scrKey.indexOf(section) > -1
									@scope.suggestionsCarouselReady[scrKey] = false
					else
						$(".slick-carousel-item[data-user-id=#{member.id}]", "[data-section=#{section}]").remove()
			, 100
TheArticle.ControllerModule.controller('FrontPageController', TheArticle.FrontPage)