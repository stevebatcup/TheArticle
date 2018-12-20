class TheArticle.Profile extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$rootElement'
	  '$timeout'
	  '$compile'
	  'Profile'
	  'MyProfile'
	]

	init: ->
		@scope.profile =
			isMe: window.location.pathname is "/my-profile"
			loaded: false
			loadError: false
			data:
				id: null
				displayName: ""
				username: ""
				orginalUsername: ""
				ratings: 0
				followers: 0
				following: 0
				joined: ""
				joinedAt: ""
				location: ""
				bio: ""
				isNew: true
			errors:
				main: false
				displayName: false
				username: false

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

	editProfile: (section=null) =>
		tpl = $("#editProfileForm").html().trim()
		$formContent = @compile(tpl)(@scope)
		$('body').append $formContent
		$("#editProfileFormModal").modal()
		@timeout =>
			$("#user_#{section}", ".form-group").focus()
		, 500

	saveProfile: ($event) =>
		$event.preventDefault()
		@scope.mode = 'view'
		@validateProfile @updateProfile

	validateProfile: (callback=null) =>
		@scope.profile.errors.displayName = @scope.profile.errors.username = @scope.profile.errors.main = false
		if !@scope.profile.data.displayName?
			@scope.profile.errors.displayName = "Please choose a Display Name"
		else if !(/^[a-z][a-z\s]*$/i.test(@scope.profile.data.displayName))
			@scope.profile.errors.displayName = "Your Display Name can only contain letters and a space"
		else if !@scope.profile.data.username?
			@scope.profile.errors.username = "Please enter a username"
		else if @scope.profile.data.username.length < 6
			@scope.profile.errors.username = "Your Username must be at least 6 characters long"
		else if !(/^[0-9a-zA-Z_]+$/i.test(@scope.profile.data.username))
			@scope.profile.errors.username = "Your Username can only contain letters, numbers and an '_'"

		if @scope.profile.errors.displayName or @scope.profile.errors.username
			return false
		else
			if "@#{@scope.profile.data.username}" is @scope.profile.data.originalUsername
				callback.call(@) if callback?
			else
				@http.get("/username-availability?username=@#{@scope.profile.data.username}").then (response) =>
					if response.data is false
						@scope.profile.errors.username = "Username has already been taken"
						return false
					else
						callback.call(@) if callback?

	updateProfile: =>
		@scope.profile.data.originalUsername = "@#{@scope.profile.data.username}"
		profile = new @MyProfile @setProfileData(@scope.profile.data)
		profile.update().then (response) =>
			if response.status is 'error'
				@updateProfileError response.message
			else
				@timeout =>
					$('button[data-dismiss=modal]', '#editProfileFormModal').click()
				, 750
		, (error) =>
			@updateProfileError error.statusText

	updateProfileError: (msg) =>
		@scope.profile.errors.main = "Error updating profile: #{msg}"

	setProfileData: (profile) =>
		{
			id: profile.id
			displayName: profile.displayName
			username: "@#{profile.username}"
			location: profile.location
			bio: profile.bio
		}

	editProfilePhoto: =>
		console.log 'editProfilePhoto'

	editCoverPhoto: =>
		console.log 'editCoverPhoto'

TheArticle.ControllerModule.controller('ProfileController', TheArticle.Profile)