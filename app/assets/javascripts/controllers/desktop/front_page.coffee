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
		console.log "FrontPage yay!"

	bindEvents: =>
		super
		$(document).on 'show.bs.tab', 'a[data-toggle="tab"]', (e) =>
			$hiding = $(e.relatedTarget)
			if $hiding.hasClass('search_trigger')
				@toggleSearch()

TheArticle.ControllerModule.controller('FrontPageController', TheArticle.FrontPage)