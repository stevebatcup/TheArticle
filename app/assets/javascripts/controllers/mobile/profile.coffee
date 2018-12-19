class TheArticle.Profile extends TheArticle.MobilePageController

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
			isMe: if 'root' of @scope then true else false
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
		@bindEvents()
		if @scope.profile.isMe is true
			@getMyProfile()
		else
			id = @rootElement.data('id')
			@getProfile(id)

	bindEvents: =>
		super unless @scope.profile.isMe

		# Broadcast from the router
		@scope.$on 'edit_profile', =>
			@editProfile()
		@scope.$on 'edit_profile_photo', =>
			@editProfilePhoto()
		@scope.$on 'edit_cover_photo', =>
			@editCoverPhoto()

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

	editProfile: (section=null) =>
		if section
			console.log "editProfile: #{section}"
		else
			console.log 'editProfile'

	editProfilePhoto: =>
		console.log 'editProfilePhoto'

	editCoverPhoto: =>
		console.log 'editCoverPhoto'

TheArticle.ControllerModule.controller('ProfileController', TheArticle.Profile)