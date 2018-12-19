class TheArticle.Profile extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$rootElement'
	  '$timeout'
	  'Profile'
	  'MyProfile'
	]

	init: ->
		@scope.profile =
			isMe: window.location.pathname is "/my-profile"
			loaded: false
			loadError: false
			data:
				displayName: ""
				username: ""
				ratings: 0
				followers: 0
				following: 0
				joined: ""
				joinedAt: ""
				location: ""
				bio: ""
				isNew: true

		if @scope.profile.isMe is true
			@getMyProfile()
		else
			id = @rootElement.data('id')
			@getProfile(id)

	getMyProfile: =>
		@MyProfile.get().then (profile) =>
			@timeout =>
				@scope.profile.data = profile
				@scope.profile.loaded = true
			, 750
		, (error) =>
			@scope.profile.loaded = true
			@scope.profile.loadError = "Sorry there has been an error loading this profile: #{error.statusText}"

	getProfile:(id) =>
		@Profile.get({id: @rootElement.data('user-id')}).then (profile) =>
			@timeout =>
				@scope.profile.data = profile
				@scope.profile.loaded = true
			, 750
		, (error) =>
			@scope.profile.loaded = true
			@scope.profile.loadError = "Sorry there has been an error loading this profile: #{error.statusText}"

TheArticle.ControllerModule.controller('ProfileController', TheArticle.Profile)