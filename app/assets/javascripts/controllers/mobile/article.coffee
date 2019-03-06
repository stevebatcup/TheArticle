class TheArticle.Article extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$element'
	  '$rootScope'
	  '$timeout'
	  '$compile'
	  '$cookies'
	]

	init: ->
		@rootScope.isSignedIn = !!@element.data('signed-in')
		@bindEvents()

		if ($('#flash_notice').length > 0) and (@cookies.get('ok_to_flash'))
			@flash $('#flash_notice').html()
			@cookies.remove('ok_to_flash')

	bindEvents: ->
		super
		@scope.$on 'swap_share_panel', (e, data) =>
			$("#sharingPanelModal").modal('hide')
			@timeout =>
				@openSharingPanel(null, data.mode)
				if data.startedComments.length > 0
					@timeout =>
						@rootScope.$broadcast 'copy_started_comments', { comments: data.startedComments }
					, 500
			, 350

TheArticle.ControllerModule.controller('ArticleController', TheArticle.Article)