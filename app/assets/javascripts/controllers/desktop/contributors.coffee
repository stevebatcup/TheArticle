class TheArticle.Contributors extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$element'
	  '$timeout'
	  '$compile'
	  'ContributorArticle'
	]

	init: ->
		@bindEvents()
		@scope.contributorArticles =
			page: 1
			items: []
			totalItemCount: 0
			firstLoaded: false
			loading: false
			moreToLoad: true
		@scope.author = @element.data('author')
		@getArticles() if @scope.author

	bindEvents: ->
		super

	loadMore: =>
		@getArticles()

	getArticles: =>
		@scope.contributorArticles.loading = true
		timeoutDelay = if @scope.contributorArticles.page is 1 then 1200 else 1
		vars = { author: @scope.author, page: @scope.contributorArticles.page, perPage: @element.data('per-page') }
		@ContributorArticle.query(vars).then (response) =>
			@timeout =>
				@scope.contributorArticles.totalItemCount = response.total if @scope.contributorArticles.page is 1
				angular.forEach response.articles, (article) =>
					@scope.contributorArticles.items.push article
				@scope.contributorArticles.moreToLoad = @scope.contributorArticles.totalItemCount > @scope.contributorArticles.items.length
				@scope.contributorArticles.firstLoaded = true if @scope.contributorArticles.page is 1
				@scope.contributorArticles.loading = false
				@scope.contributorArticles.page += 1
			, timeoutDelay
		, (response) =>
			@refreshPage() if response.status is 401

TheArticle.ControllerModule.controller('ContributorsController', TheArticle.Contributors)