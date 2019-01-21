class TheArticle.AccountSettings extends TheArticle.mixOf TheArticle.DesktopPageController, TheArticle.PageTransitions

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$rootElement'
	  '$timeout'
	  '$compile'
	  'AccountSettings'
	  'Profile'
	]

	init: ->
		@setDefaultHttpHeaders()
		@scope.pageHistory = []
		@scope.showBackPage = false
		@scope.pageTitle = 'Settings'
		@scope.connects =
			data: []
			loaded: false
		@scope.mutes =
			data: []
			loaded: false
		@scope.blocks =
			data: []
			loaded: false
		@scope.blocks = []
		@scope.user = {}
		@scope.profile = {}
		@bindEvents()
		@getUser()

	bindEvents: ->
		@listenForBack()
		@scope.$on 'page_moved_forward', ($event, data) =>
			@scope.showBackPage = true
			@scope.pageTitle = data.title

		@scope.$on 'page_moved_back', ($event, data) =>
			@scope.showBackPage = data.showBack
			@scope.pageTitle = data.title
			@scope.user.confirmingPassword = ''

		@scope.$on 'account_subpage_selected', ($event, data) =>
			@timeout =>
				@resetPages()
				@timeout =>
					@forwardToPage(null, data.page)
				, 350
			, 350


	backPage: ($event) =>
		$event.preventDefault()
		@rootScope.$broadcast 'page_moving_back'

	getUser: =>
		@AccountSettings.get({me: true}).then (settings) =>
			@scope.user = settings.user
			@getProfile()

	getConnects: =>
		unless @scope.connects.loaded
			@http.get("/connects").then (response) =>
				@scope.connects.data = response.data.connects
				@timeout =>
					@scope.connects.loaded = true
				, 900

	getMutes: =>
		unless @scope.mutes.loaded
			@http.get("/mutes").then (response) =>
				@scope.mutes.data = response.data.mutes
				@timeout =>
					@scope.mutes.loaded = true
				, 900

	getBlocks: =>
		unless @scope.blocks.loaded
			@http.get("/blocks").then (response) =>
				@scope.blocks.data = response.data.blocks
				@timeout =>
					@scope.blocks.loaded = true
				, 900

	unmute: (item, $event) =>
		$event.preventDefault()
		console.log "unmute user #{item.id}"

	unblock: (item, $event) =>
		$event.preventDefault()
		console.log "unblock user #{item.id}"

	getProfile: =>
		@Profile.get({id: @scope.user.id}).then (profile) =>
			@scope.profile = profile

	saveNames: ($event) =>
		$event.preventDefault() if $event?
		console.log 'saveNames'

	saveUsername: ($event) =>
		$event.preventDefault() if $event?
		console.log 'saveUsername'

	saveEmail: ($event) =>
		$event.preventDefault() if $event?
		console.log 'saveEmail'

	savePassword: ($event) =>
		$event.preventDefault() if $event?
		console.log 'savePassword'

	deleteAccount: ($event) =>
		$event.preventDefault() if $event?
		console.log 'deleteAccount'

	deactivateProfile: ($event) =>
		$event.preventDefault() if $event?
		console.log 'deactivateProfile'

	editProfile: ($event) =>
		$event.preventDefault() if $event?
		window.location.href = "/my-profile"

	reactivateProfile: ($event) =>
		$event.preventDefault() if $event?
		console.log 'reactivateProfile'

TheArticle.ControllerModule.controller('AccountSettingsController', TheArticle.AccountSettings)