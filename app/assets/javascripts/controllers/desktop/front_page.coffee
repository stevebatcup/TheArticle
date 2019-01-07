class TheArticle.FrontPage extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$element'
	  '$timeout'
	  'Feed'
	]

	init: ->
		@bindEvents()
		vars = @getUrlVars()
		@scope.showWelcome = if 'from_wizard' of vars then true else false

		@timeout =>
			@alert "It looks like you have already completed the profile wizard!", "Wizard completed" if 'wizard_already_complete' of vars
		, 500

		@scope.feeds =
			data: []
			loaded: false
		@getFeeds()

	bindEvents: =>
		super
		$(document).on 'show.bs.tab', 'a[data-toggle="tab"]', (e) =>
			$hiding = $(e.relatedTarget)
			if $hiding.hasClass('search_trigger')
				@toggleSearch()

	getFeeds: =>
		@Feed.query().then (response) =>
			console.log response
			@scope.feeds.data = response
			@scope.feeds.loaded = true


TheArticle.ControllerModule.controller('FrontPageController', TheArticle.FrontPage)