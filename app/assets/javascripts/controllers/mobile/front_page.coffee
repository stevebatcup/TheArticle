class TheArticle.FrontPage extends TheArticle.MobilePageController

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
		vars = @getUrlVars()
		@scope.showWelcome = if 'from_wizard' of vars then true else false

		@timeout =>
			@alert "It looks like you have already completed the profile wizard!", "Wizard completed" if 'wizard_already_complete' of vars
		, 500

	bindEvents: =>
		$(document).on 'show.bs.tab', 'a[data-toggle="tab"]', (e) =>
			$showing = $(e.target)
			$hiding = $(e.relatedTarget)

			if $hiding.attr('id') is 'search-tab' or $showing.attr('id') is 'search-tab'
				@toggleSearch()

			if $showing.attr('id') is 'notifications-tab'
				@scope.$apply =>
					@scope.root.notifications = true
			else
				@scope.$apply =>
					@scope.root.notifications = false
				true

TheArticle.ControllerModule.controller('FrontPageController', TheArticle.FrontPage)