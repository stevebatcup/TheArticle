class TheArticle.FrontPage extends TheArticle.DesktopPageController

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
		super
		$(document).on 'show.bs.tab', 'a[data-toggle="tab"]', (e) =>
			$hiding = $(e.relatedTarget)
			if $hiding.hasClass('search_trigger')
				@toggleSearch()


TheArticle.ControllerModule.controller('FrontPageController', TheArticle.FrontPage)