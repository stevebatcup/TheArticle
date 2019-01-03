class TheArticle.SearchResults extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$element'
	  '$timeout'
	  '$sce'
	]

	init: ->
		@scope.selectedTab = 'all'
		@setDefaultHttpHeaders()
		@scope.search =
			allLimit: 6
			query: @element.data('query')
			results:
				loaded: false
				data:
					articles: []
					contributors: []
					profiles: []
					exchanges: []
					posts: []
		@bindEvents()
		@getResults()

	getResults: =>
		@http.get("/search?query=#{@scope.search.query}").then (response) =>
			angular.forEach response.data.results, (result) =>
				@scope.search.results.data[result.type].push result
			console.log @scope.search.results.data
			@scope.search.results.loaded = true

	selectTab: (tab='all') =>
		@scope.selectedTab = tab

	filterListForTab: (list) =>
		if @scope.selectedTab == 'all'
			list.slice(0, @scope.search.allLimit)
		else
			list

	toggleFollowUserFromCard: (member, $event) =>
		$event.preventDefault()
		if member.imFollowing
			@unfollowUser member.id, =>
				member.imFollowing = false
		else
			@followUser member.id, =>
				member.imFollowing = true
			, false

	toggleFollowExchangeFromCard: (exchange, $event) =>
		$event.preventDefault()
		if exchange.imFollowing
			@unfollowExchange exchange.id, =>
				exchange.imFollowing = false
		else
			@followExchange exchange.id, =>
				exchange.imFollowing = true


TheArticle.ControllerModule.controller('SearchResultsController', TheArticle.SearchResults)