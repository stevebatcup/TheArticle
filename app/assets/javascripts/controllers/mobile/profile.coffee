class TheArticle.Profile extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$timeout'
	  '$sce'
	  '$compile'
	  'Profile'
	  'MyProfile'
	]

	init: ->
		@setDefaultHttpHeaders()
		@scope.profilePhotoReadyForCrop = false
		@scope.mode = 'view'
		@scope.selectedTab = 'all'
		@scope.allExchanges = []
		@scope.profile =
			allLimit: 2
			isMe: window.location.pathname is "/my-profile"
			loaded: false
			loadError: false
			digest: []
			data:
				id: null
				displayName: ""
				username: ""
				orginalUsername: ""
				followers: []
				followings: []
				exchanges: []
				shares: []
				ratingsSummary: []
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
		if @scope.profile.isMe is true
			@getMyProfile @getUserExchanges
		else
			id = @element.data('id')
			@getProfile id, @getUserExchanges

	bindEvents: =>
		super

		$(document).on 'click', "#upload_profilePhoto_btn", (e) =>
			$("#profilePhoto_uploader").focus().trigger('click')

		$(document).on 'click', "#upload_coverPhoto_btn", (e) =>
			$("#coverPhoto_uploader").focus().trigger('click')

		@scope.$watch 'profile.data.profilePhoto.source', (newVal, oldVal) =>
			if (oldVal isnt newVal) and newVal.length > 0
				@showProfilePhotoCropper document.getElementById('profilePhoto_holder'), 275, 275, 'circle'

		@scope.$watch 'profile.data.coverPhoto.source', (newVal, oldVal) =>
			if (oldVal isnt newVal) and newVal.length > 0
				@showProfilePhotoCropper document.getElementById('coverPhoto_holder'), 300, 100, 'square'

		# Broadcast from HeaderBarController
		@scope.$on 'edit_profile', =>
			@editProfile()
		@scope.$on 'edit_profile_photo', =>
			@editProfilePhoto()
		@scope.$on 'edit_cover_photo', =>
			@editCoverPhoto()

		# Broadcast from FollowsController
		@scope.$on 'follows_panel_close', =>
			@scope.mode = 'view'

	selectTab: (tab='all', $event) =>
		$event.preventDefault()
		@scope.selectedTab = tab
		console.log @scope.selectedTab
		$('#feed').scrollTop(0)
		pos = $('#public_activity').position().top - 50
		$(window).scrollTop(pos)

	filterListForTab: (list) =>
		if @scope.selectedTab == 'all'
			list.slice(0, @scope.profile.allLimit)
		else
			list

	getUserExchanges: =>
		url = if @scope.profile.isMe then "/user_exchanges" else "/user_exchanges/#{@scope.profile.data.id}"
		@http.get(url).then (exchanges) =>
			@scope.profile.data.exchanges = exchanges.data.exchanges
			@scope.allExchanges = @sortExchangesByName(exchanges.data.exchanges)
			angular.forEach @scope.profile.data.exchanges, (item) =>
				item.type = 'exchange'
				@scope.profile.digest.push item
			@reorderDigest()

	sortExchangesByName: (list) =>
		list.sort (a,b) =>
			a[0]-b[0]

	reorderDigest: =>
		@scope.profile.digest.sort (a,b) =>
			new Date(b.stamp*1000) - new Date(a.stamp*1000)

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

	getMyProfile: (callback=null) =>
		@MyProfile.get().then (profile) =>
			@timeout =>
				@scope.profile.data = profile
				console.log @scope.profile.data
				@scope.profile.loaded = true
				@buildDigestFromProfileData(@scope.profile.data)
				@reorderDigest()
				callback.call(@) if callback?
			, 750
		, (error) =>
			@scope.profile.loaded = true
			@scope.profile.loadError = "Sorry there has been an error loading this profile: #{error.statusText}"

	getProfile:(id, callback=null) =>
		@Profile.get({id: @element.data('user-id')}).then (profile) =>
			@timeout =>
				@scope.profile.data = profile
				@scope.profile.loaded = true
				@buildDigestFromProfileData(@scope.profile.data)
				@reorderDigest()
				callback.call(@) if callback?
			, 750
		, (error) =>
			@scope.profile.loaded = true
			@scope.profile.loadError = "Sorry there has been an error loading this profile: #{error.statusText}"

	buildDigestFromProfileData: (data) =>
		angular.forEach data.shares, (item) =>
			item.type = 'share'
			@scope.profile.digest.push item
		angular.forEach data.ratings, (item) =>
			item.type = 'rating'
			@scope.profile.digest.push item

		item = data.recentFollowingSummary
		item.type = 'recentFollowingSummary'
		@scope.profile.digest.push item

		item = data.recentFollowedSummary
		item.type = 'recentFollowedSummary'
		@scope.profile.digest.push item

	editProfile: =>
		return false unless @scope.profile.isMe
		@scope.mode = 'edit'

	saveProfile: ($event) =>
		$event.preventDefault()
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
				@scope.mode = 'view'
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

	cancelEditProfile: =>
		@scope.mode = 'view'

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

	toggleFollowUser: =>
		if @scope.profile.data.imFollowing
			@unfollowUser @scope.profile.data.id, =>
				@scope.profile.data.imFollowing = false
		else
			@followUser @scope.profile.data.id, =>
				@scope.profile.data.imFollowing = true
			, false

	openFollowsPanel: (tab='following') =>
		@scope.mode = 'follows'
		@timeout =>
			$("#follows-sub-tab-#{tab}").click()
			@rootScope.$broadcast('follows_panel_open', tab)
		, 300

	openExchangesModal: ($event) =>
		$event.preventDefault()
		@timeout =>
			tpl = $("#allUserExchanges").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#allUserExchangesModal").modal()
		, 350

TheArticle.ControllerModule.controller('ProfileController', TheArticle.Profile)