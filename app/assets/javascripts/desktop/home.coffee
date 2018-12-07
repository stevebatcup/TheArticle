class TheArticle.Home extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$rootElement'
	  '$timeout'
	  'EditorsPick'
	]

	init: ->
		@bindEvents()
		@scope.moreToLoad = true
		@scope.page = 1
		@scope.editorsPicks = []
		@scope.totalEditorsPicks = 0
		@scope.loaded = false
		@getEditorsPicks()

	bindEvents: =>
		super
		$('.see_more_articles').on 'click', (e) =>
			$clicked = $(e.currentTarget)
			nextSection = Number($clicked.data('section')) + 1
			$clicked.hide().parent().find("a[data-section=#{nextSection}]").show()

	loadMore: =>
		@getEditorsPicks()

	getEditorsPicks: =>
		timeoutDelay = if @scope.page is 1 then 1000 else 1
		vars = { tagged: 'editors-picks', page: @scope.page }
		@EditorsPick.query(vars).then (response) =>
			@timeout =>
				@scope.loaded = true
				console.log response
				@scope.totalEditorsPicks = response.total if @scope.page is 1
				angular.forEach response.articles, (article) =>
					@scope.editorsPicks.push article
				@scope.moreToLoad = @scope.totalEditorsPicks > @scope.editorsPicks.length
				@scope.page += 1
			, timeoutDelay
		, (response) =>
			@refreshPage() if response.status is 401


TheArticle.ControllerModule.controller('HomeController', TheArticle.Home)