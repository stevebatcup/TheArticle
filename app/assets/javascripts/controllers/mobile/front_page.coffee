class TheArticle.FrontPage extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
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
		$(document).on 'show.bs.tab', 'a[data-toggle="tab"]', (e) =>
			$showing = $(e.target)
			$hiding = $(e.relatedTarget)

			if $hiding.attr('id') is 'search-tab' or $showing.attr('id') is 'search-tab'
				@rootScope.$broadcast('search-tab-clicked')

			if $showing.attr('id') is 'notifications-tab'
				@scope.$apply =>
					@scope.root.notifications = true
			else
				@scope.$apply =>
					@scope.root.notifications = false
				true

	getFeeds: =>
		@Feed.query().then (response) =>
			console.log response
			@scope.feeds.data = response
			@scope.feeds.loaded = true


TheArticle.ControllerModule.controller('FrontPageController', TheArticle.FrontPage)