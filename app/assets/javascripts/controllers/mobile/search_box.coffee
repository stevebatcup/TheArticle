class TheArticle.SearchBox extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$rootElement'
	  '$timeout'
	]

	init: ->
		@setDefaultHttpHeaders()
		@scope.search =
			query: ''
			suggestions:
				loaded: false
				data:
					topics: []
					exchanges: []
					contributors: []
					profiles: []
					suggestionsMode: ''
					recentSearches: []
					whoToFollow: []
					trendingArticles: []
					trendingExchanges: []
		@bindEvents()

	bindEvents: ->
		@scope.$on 'search-tab-clicked', =>
			@toggleSearch()

		$('.search_trigger').on 'click', (e) =>
			@toggleSearch()

		@scope.$watch 'search.query', (newVal, oldVal) =>
			@getSearchSuggestions() if newVal isnt oldVal

	toggleSearch: =>
		$box = $('#search_box')
		if $box.is(':hidden')
			$box.slideDown(200)
			$box.find('input[name=query]').focus()
			$('#ads_top').hide()
			$('.wrapper').addClass('no-scroll')
			@getSearchSuggestions() unless @scope.search.suggestions.loaded
		else
			$box.slideUp(200)
			$('#ads_top').show()
			$('.wrapper').removeClass('no-scroll')

	getSearchSuggestions: =>
		if @scope.search.query.length > 1
			query = @scope.search.query
		else
			query = ''
		@http.get("/search-suggestions?query=#{query}").then (response) =>
			@scope.search.suggestions.data = response.data
			@scope.search.suggestions.loaded = true

	chooseSearchTerm: (term, submitForm=false) =>
		@scope.search.query = term
		if submitForm
			@timeout =>
				$('#search_submitter').click()
			, 500
		else
			$('input#search_query').focus()

	removeSeachItem: (searchItem, list) =>
		@scope.search.suggestions.data[list] = _.filter @scope.search.suggestions.data[list], (item) =>
			item.term isnt searchItem.term

TheArticle.ControllerModule.controller('SearchBoxController', TheArticle.SearchBox)