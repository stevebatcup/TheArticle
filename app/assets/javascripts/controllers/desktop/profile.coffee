class TheArticle.Profile extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$rootElement'
	  '$timeout'
	  '$compile'
	  '$sce'
	  'Profile'
	  'MyProfile'
	]

	init: ->
		@getVars = @getUrlVars()
		@setDefaultHttpHeaders()
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
				followers: []
				followings: []
				exchanges: []
				shares: []
				ratings: []
				joined: ""
				joinedAt: ""
				location: ""
				bio: ""
				isNew: true
				imFollowing: false
				profilePhoto:
					image: ""
					source: ""
				coverPhoto:
					image: ""
					source: ""
			errors:
				main: false
				displayName: false
				username: false
				photo: false
		@bindEvents()
		@detectPanelOpeners() if 'panel' of @getVars
		if @scope.profile.isMe is true
			@getMyProfile @getUserExchanges
		else
			id = @rootElement.data('id')
			@getProfile id, @getUserExchanges

	bindEvents: =>
		$(document).on 'click', "#upload_profilePhoto_btn", (e) =>
			$("#profilePhoto_uploader").focus().trigger('click')

		$(document).on 'click', "#upload_coverPhoto_btn", (e) =>
			$("#coverPhoto_uploader").focus().trigger('click')

		@scope.$watch 'profile.data.profilePhoto.source', (newVal, oldVal) =>
			if (oldVal isnt newVal) and newVal.length > 0
				@showProfilePhotoCropper document.getElementById('profilePhoto_holder'), 300, 300, 'circle'

		@scope.$watch 'profile.data.coverPhoto.source', (newVal, oldVal) =>
			if (oldVal isnt newVal) and newVal.length > 0
				@showProfilePhotoCropper document.getElementById('coverPhoto_holder'), 425, 82, 'square'

	detectPanelOpeners: =>
		if @getVars['panel'] is 'following'
			@timeout =>
				$('#activity-following-tab').click()
			, 750
		else if @getVars['panel'] is 'followers'
			@timeout =>
				$('#activity-followers-tab').click()
			, 750


	getUserExchanges: =>
		url = if @scope.profile.isMe then "/user_exchanges" else "/user_exchanges/#{@scope.profile.data.id}"
		@http.get(url).then (exchanges) =>
			@scope.profile.data.exchanges = exchanges.data.exchanges

	showProfilePhotoCropper: (element, width, height, shape) =>
		type = $(element).data('type')
		c = new Croppie element,
			viewport:
				width: width
				height: height
				type: shape
			update: =>
				c.result('canvas').then (img) =>
					@scope.$apply =>
						@scope.profile.data[type].image = img

	saveCroppedPhoto: ($event, type) =>
		$event.preventDefault()
		profile = new @MyProfile({id: @scope.profile.data.id, photo: @scope.profile.data[type].image, mode: type })
		profile.update().then (response) =>
			if response.status is 'error'
				@savePhotoError response.message
			else
				@timeout =>
					$('button[data-dismiss=modal]', "#edit#{type}Modal").click()
				, 750
		, (error) =>
			@savePhotoError error.statusText

	savePhotoError: (msg) =>
		@scope.profile.errors.photo = "Error uploading new photo: #{msg}"

	getMyProfile: (callback=null) =>
		@MyProfile.get().then (profile) =>
			@timeout =>
				@scope.profile.data = profile
				@scope.profile.loaded = true
				callback.call(@) if callback?
			, 750
		, (error) =>
			@scope.profile.loaded = true
			@scope.profile.loadError = "Sorry there has been an error loading this profile: #{error.statusText}"

	getProfile: (id, callback=null) =>
		@Profile.get({id: @rootElement.data('user-id')}).then (profile) =>
			@timeout =>
				@scope.profile.data = profile
				@scope.profile.loaded = true
				callback.call(@) if callback?
			, 750
		, (error) =>
			@scope.profile.loaded = true
			@scope.profile.loadError = "Sorry there has been an error loading this profile: #{error.statusText}"

	editProfile: (section=null) =>
		return false unless @scope.profile.isMe
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
		return false unless @scope.profile.isMe
		tpl = $("#editProfilePhoto").html().trim()
		$content = @compile(tpl)(@scope)
		$('body').append $content
		$("#editprofilePhotoModal").modal()

	editCoverPhoto: =>
		return false unless @scope.profile.isMe
		tpl = $("#editCoverPhoto").html().trim()
		$content = @compile(tpl)(@scope)
		$('body').append $content
		$("#editcoverPhotoModal").modal()

	toggleFollowUser: =>
		userId = @scope.profile.data.id
		if @scope.profile.data.imFollowing
			@unfollowUser userId, =>
				@scope.profile.data.imFollowing = false
		else
			@followUser userId, =>
				@scope.profile.data.imFollowing = true
			, false

	toggleFollowUserFromCard: (member) =>
		if member.imFollowing
			@unfollowUser member.id ,=>
				@scope.profile.data.followings = _.filter @scope.profile.data.followings, (item) =>
					item.id isnt member.id
				if followerItem = _.findWhere @scope.profile.data.followers, { id: member.id }
					followerItem.imFollowing = false
				member.imFollowing = false
		else
			@followUser member.id, =>
				member.imFollowing = true
				@scope.profile.data.followings.push member
			, false


TheArticle.ControllerModule.controller('ProfileController', TheArticle.Profile)