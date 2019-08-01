class TheArticle.Profile extends TheArticle.mixOf TheArticle.DesktopPageController, TheArticle.Feeds, TheArticle.PhotoEditor

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$timeout'
	  '$compile'
	  '$sce'
	  '$ngConfirm'
	  '$cookies'
	  'Profile'
	  'MyProfile'
	  'Comment'
	  'Opinion'
	]

	init: ->
		$('footer#main_footer_top, footer#main_footer_bottom').hide()
		if ($('#flash_notice').length > 0) and (@cookies.get('ok_to_flash'))
			@flash $('#flash_notice').html()
			@cookies.remove('ok_to_flash')
		@getVars = @getUrlVars()
		@setDefaultHttpHeaders()
		@rootScope.isSignedIn = false
		@$navBar = $('section#top_bar')
		@$navBarPosition = Math.round @$navBar.offset().top
		@$navBarHeight = @$navBar.outerHeight()
		@scope.selectedTab = 'all'
		@scope.allExchanges = []
		@scope.replyingToComment =
			comment: {}
			parentComment: {}
			replyingToReply: false
		@scope.postingComment = false
		@scope.commentPostButton = "Post Comment"
		@scope.commentForSubmission =
			value: ''
		@scope.commentChildLimit = false
		@scope.authActionMessage =
			heading: ''
			msg: ''
		@scope.photoCrop =
			cropper: {}
			scaleX: 1
			scaleY: 1
		@scope.profile =
			isMe: window.location.pathname is "/my-profile"
			loaded: false
			loadError: false
			digest: []
			follows:
				followings: []
				followers: []
				connections: []
				followersMode: 'all'
				page: 1
				perPage: 10
				moreToLoad: true
				totalItems: 0
			shares:
				data: []
				page: 1
				perPage: 10
				moreToLoad: true
				totalItems: 0
			ratings:
				data: []
				page: 1
				perPage: 10
				moreToLoad: true
				totalItems: 0
			exchanges:
				data: []
				page: 1
				perPage: 10
				moreToLoad: true
				totalItems: 0
			opinionActions:
				data: []
				page: 1
				perPage: 10
				moreToLoad: true
				totalItems: 0
			commentActions:
				data: []
				page: 1
				perPage: 10
				moreToLoad: true
				totalItems: 0
			form:
				edited: false
				data:
					displayName: ""
					username:
						value: ""
						available: true
					location:
						text: ""
						lat: null
						lng: null
						countryCode: ''
					bio: ""
			data:
				id: null
				displayName: ""
				username: ""
				orginalUsername: ""
				recentFollowingSummary: ""
				recentFollowedSummary: ""
				imFollowingCount: 0
				ratingsCount: 0
				sharessCount: 0
				ratingsSummary: []
				commentActions: []
				joined: ""
				joinedAt: ""
				location: ""
				bio: ""
				isNew: true
				imFollowing: false
				followingsCount: 0
				followersCount: 0
				connectionsCount: 0
				profilePhoto:
					image: ""
					source: ""
					uploading: false
					width: 0
					height: 0
				coverPhoto:
					image: ""
					source: ""
					uploading: false
					width: 0
					height: 0
				confirmingPassword: ''
			errors:
				main: false
				displayName: false
				username: false
				photo: false
				reactivate: false
				location: false

		@bindEvents()
		@detectPanelOpeners() if 'panel' of @getVars
		@scope.tinymceOptions = @setTinyMceOptions()

		if @scope.profile.isMe is true
			@rootScope.isSignedIn = true
			@getMyProfile @getProfileCallback
			@scope.thirdPartyUrl =
				value: ''
				building: false
		else
			id = @element.data('id')
			@getProfile id, @getProfileCallback
			@getMyProfile null, true

	getProfileCallback: =>
		@getUserExchanges()
		@getFollows()
		@getShares()
		@getRatings()
		@getCommentActions()
		@getOpinionActions()

	bindEvents: =>
		@listenForActions()

		$(document).on 'click', "#upload_profilePhoto_btn", (e) =>
			$("#profilePhoto_uploader").focus().trigger('click')

		$(document).on 'click', "#upload_coverPhoto_btn", (e) =>
			$("#coverPhoto_uploader").focus().trigger('click')

		$(document).on 'click', ".open_ratings_tab", (e) =>
			e.preventDefault()
			@openRatingsTab()

		@scope.$watch 'profile.data.profilePhoto.source', (newVal, oldVal) =>
			if (oldVal isnt newVal) and newVal.length > 0
				@showProfilePhotoCropper document.getElementById('profilePhoto_holder'), @scope.profile.data.profilePhoto.width, @scope.profile.data.profilePhoto.height

		@scope.$watch 'profile.data.coverPhoto.source', (newVal, oldVal) =>
			if (oldVal isnt newVal) and newVal.length > 0
				@showProfilePhotoCropper document.getElementById('coverPhoto_holder'), @scope.profile.data.coverPhoto.width, @scope.profile.data.coverPhoto.height

		$(document).on 'keyup', 'input#user_location', (e) =>
			$input = $('input#user_location')
			value = $input.val()
			if value.length > 2
				@autocompleteLocations $input

		@scope.$on 'update_follows_from_suggestions', (e, data) =>
			@resetFollows()
			if data.action is 'follow'
				@scope.profile.data.followingsCount += 1
			else
				@scope.profile.data.followingsCount -= 1

		$(document).on 'click', ".mentioned_user", (e) =>
			$clicked = $(e.currentTarget)
			userId = $clicked.data('user')
			window.location.href = "/profile-by-id/#{userId}"

		$(document).on 'click', ".bio_click", (e) =>
			$clicked = $(e.currentTarget)
			url = $clicked.data('href')
			window.location.href = url

	denoteUploading: (element) =>
		type = $(element).data('type')
		@scope.profile.data["#{type}Photo"].uploading = true
		@scope.profile.errors.photo = ""

	imageUploadError: (error, element) =>
		type = $(element).data('type')
		@scope.profile.errors.photo = error
		@timeout =>
			@scope.profile.data["#{type}Photo"].uploading = false
		, 300

	actionRequiresSignIn: ($event, action) =>
		$event.preventDefault()
		@requiresSignIn(action, window.location.pathname)

	selectTab: (tab='all') =>
		@scope.selectedTab = tab
		# console.log @$navBarHeight
		if ($('[data-fixed-profile-nav]').length > 0) and ($('body').hasClass('fixed-profile-nav'))
			$(window).scrollTop(@$navBarPosition - @$navBarHeight - 160)

	detectPanelOpeners: =>
		if @getVars['panel'] is 'edit_profile'
			@timeout =>
				$('#edit_profile_btn').click()
			, 350
		else
			@timeout =>
				$("#activity-#{@getVars['panel']}-tab").click()
			, 750

	loadMoreRatings: =>
		@scope.profile.ratings.page += 1
		@getRatings()

	getRatings: =>
		url = "/user_ratings/#{@scope.profile.data.id}?page=#{@scope.profile.ratings.page}&per_page=#{@scope.profile.ratings.perPage}"
		@http.get(url).then (response) =>
			angular.forEach response.data.ratings, (item) =>
				@scope.profile.ratings.data.push item
			@scope.profile.ratings.totalItems = response.data.total if @scope.profile.ratings.page is 1
			@scope.profile.ratings.moreToLoad = @scope.profile.ratings.totalItems > (@scope.profile.ratings.page * @scope.profile.ratings.perPage)
			@scope.profile.ratings.loaded = true
		 if @scope.profile.ratings.moreToLoad is true
				@timeout =>
					@loadMoreRatings()
				, 500
			# for the 'All' tab
			angular.forEach response.data.ratings, (item) =>
				item.type = 'rating'
				@scope.profile.digest.push item
			@reorderDigest()

	loadMoreShares: =>
		@scope.profile.shares.page += 1
		@getShares()

	getShares: =>
		url = "/user_shares/#{@scope.profile.data.id}?page=#{@scope.profile.shares.page}&per_page=#{@scope.profile.shares.perPage}"
		@http.get(url).then (response) =>
			angular.forEach response.data.shares, (item) =>
				@scope.profile.shares.data.push item
			@scope.profile.shares.totalItems = response.data.total if @scope.profile.shares.page is 1
			@scope.profile.shares.moreToLoad = @scope.profile.shares.totalItems > (@scope.profile.shares.page * @scope.profile.shares.perPage)
			@scope.profile.shares.loaded = true
		 if @scope.profile.shares.moreToLoad is true
				@timeout =>
					@loadMoreShares()
				, 500
			# for the 'All' tab
			angular.forEach response.data.shares, (item) =>
				item.type = 'share'
				@scope.profile.digest.push item
			@reorderDigest()

	loadMoreCommentActions: =>
		@scope.profile.commentActions.page += 1
		@getCommentActions()

	getCommentActions: =>
		url = "/user_comments/#{@scope.profile.data.id}?page=#{@scope.profile.commentActions.page}&per_page=#{@scope.profile.commentActions.perPage}"
		@http.get(url).then (response) =>
			angular.forEach response.data.comments, (item) =>
				@scope.profile.commentActions.data.push item
			@scope.profile.commentActions.totalItems = response.data.total if @scope.profile.commentActions.page is 1
			@scope.profile.commentActions.moreToLoad = @scope.profile.commentActions.totalItems > (@scope.profile.commentActions.page * @scope.profile.commentActions.perPage)
			@scope.profile.commentActions.loaded = true
		 if @scope.profile.commentActions.moreToLoad is true
				@timeout =>
					@loadMoreCommentActions()
				, 500
			# for the 'All' tab
			angular.forEach response.data.comments, (item) =>
				item.type = 'commentAction'
				@scope.profile.digest.push item
			@reorderDigest()


	loadMoreOpinionActions: =>
		@scope.profile.opinionActions.page += 1
		@getOpinionActions()

	getOpinionActions: =>
		url = "/user_opinions/#{@scope.profile.data.id}?page=#{@scope.profile.opinionActions.page}&per_page=#{@scope.profile.opinionActions.perPage}"
		@http.get(url).then (response) =>
			angular.forEach response.data.opinions, (item) =>
				@scope.profile.opinionActions.data.push item
			@scope.profile.opinionActions.totalItems = response.data.total if @scope.profile.opinionActions.page is 1
			@scope.profile.opinionActions.moreToLoad = @scope.profile.opinionActions.totalItems > (@scope.profile.opinionActions.page * @scope.profile.opinionActions.perPage)
			@scope.profile.opinionActions.loaded = true
		 if @scope.profile.opinionActions.moreToLoad is true
				@timeout =>
					@loadMoreOpinionActions()
				, 500
			# for the 'All' tab
			angular.forEach response.data.opinions, (item) =>
				item.type = 'opinionAction'
				@scope.profile.digest.push item
			@reorderDigest()

	resetFollows: =>
		@scope.profile.follows =
			followings: []
			followers: []
			connections: []
			followersMode: 'all'
			page: 1
			perPage: 10
			moreToLoad: true
			totalItems: 0
		@getFollows()

	loadMoreFollows: =>
		@scope.profile.follows.page += 1
		@getFollows()

	getFollows: =>
		url = "/user_followings/#{@scope.profile.data.id}?page=#{@scope.profile.follows.page}&per_page=#{@scope.profile.follows.perPage}"
		@http.get(url).then (response) =>
			angular.forEach response.data.list.followings, (item) =>
				@scope.profile.follows.followings.push item
			angular.forEach response.data.list.followers, (item) =>
				@scope.profile.follows.followers.push item
			@scope.profile.follows.totalItems = response.data.total if @scope.profile.follows.page is 1
			@scope.profile.follows.moreToLoad = @scope.profile.follows.totalItems > (@scope.profile.follows.page * @scope.profile.follows.perPage)
			@scope.profile.follows.loaded = true
			@buildConnections()
			if @scope.profile.follows.moreToLoad is true
				@timeout =>
					@loadMoreFollows()
				, 500

	buildConnections: =>
		results = []
		angular.forEach @scope.profile.follows.followers, (item) =>
			results.push(item) if item.isConnected
		@scope.profile.follows.connections = results

	buildFollowersImFollowingCount: =>
		results = []
		angular.forEach @scope.profile.follows.followers, (item) =>
			results.push(item) if item.imFollowing
		@scope.profile.data.imFollowingCount = results.length

	loadMoreExchanges: =>
		@scope.profile.exchanges.page += 1
		@getUserExchanges()

	getUserExchanges: =>
		url = if @scope.profile.isMe then "/user_exchanges" else "/user_exchanges/#{@scope.profile.data.id}"
		url += "?page=#{@scope.profile.exchanges.page}&per_page=#{@scope.profile.exchanges.perPage}"
		@http.get(url).then (response) =>
			angular.forEach response.data.exchanges, (item) =>
				@scope.profile.exchanges.data.push item
			@scope.profile.exchanges.totalItems = response.data.total if @scope.profile.exchanges.page is 1
			@scope.profile.exchanges.moreToLoad = @scope.profile.exchanges.totalItems > (@scope.profile.exchanges.page * @scope.profile.exchanges.perPage)
			@scope.profile.exchanges.loaded = true
			if @scope.profile.exchanges.moreToLoad is true
				@timeout =>
					@loadMoreExchanges()
				, 500
			# for the 'view all' modal
			@scope.allExchanges = @sortExchangesByName(@scope.profile.exchanges.data)
			# for the 'All' tab
			angular.forEach response.data.exchanges, (item) =>
				item.type = 'exchange'
				@scope.profile.digest.push item
			@reorderDigest()

	sortExchangesByName: (list) =>
		list.sort (a,b) =>
			a[0]-b[0]

	reorderDigest: =>
		@scope.profile.digest.sort (a,b) =>
			new Date(b.stamp*1000) - new Date(a.stamp*1000)

	showProfilePhotoCropper: (element, width, height) =>
		@scope.profile.errors.photo = ""
		type = $(element).data('type')
		@timeout =>
			@scope.profile.data[type].uploading = false
		, 500
		@scope.photoCrop.cropper = new Cropper element,
			checkOrientation: true
			checkCrossOrigin: true
			minCropBoxWidth: width
			minCropBoxHeight: height
			center: true
			cropBoxResizable: false
			viewMode: if type is 'coverPhoto' then 3 else 1
			dragMode: 'none'
		@timeout =>
			containerData = @scope.photoCrop.cropper.getContainerData()
			@scope.photoCrop.cropper.setCropBoxData
				width: width
				height: height
				left: (containerData.width / 2) - (width / 2)
				top: (containerData.height / 2) - (height / 2)
			if type is 'coverPhoto'
				@scope.photoCrop.cropper.zoomTo .5,
					x: containerData.width / 2
					y: containerData.height / 2
		, 350

	cancelEditPhoto: (type) =>
		@scope.profile.data[type].source = ''
		@scope.photoCrop.cropper.destroy()
		$("#edit#{type}Modal").modal('hide')
		$("#{type}_holder").attr("src", "")
		$("##{type}_uploader").val('')

	saveCroppedPhoto: ($event, type) =>
		$event.preventDefault()
		@scope.photoCrop.cropper.crop()
		@scope.profile.data[type].uploading = true
		settings =
			width: (@scope.profile.data[type].width * 2),
			minWidth: (@scope.profile.data[type].width * 2),
			height: (@scope.profile.data[type].height * 2),
			minHeight: (@scope.profile.data[type].height * 2),
			imageSmoothingEnabled: true,
			imageSmoothingQuality: 'high'
		@scope.photoCrop.cropper.getCroppedCanvas(settings).toBlob (blob) =>
			formData = new FormData()
			formData.append('photo', blob)
			formData.append('mode', type)
			$.ajax '/my-photo',
				method: "PUT"
				data: formData
				processData: false
				contentType: false
				success: (response) =>
					if response.status is 'error'
						@savePhotoError response.message, type
					else
						@timeout =>
							@scope.profile.data[type].image = @scope.photoCrop.cropper.getCroppedCanvas().toDataURL('image/jpeg')
							@scope.profile.data[type].uploading = false
							@cancelEditPhoto(type)
						, 750
				error: (error) =>
					@savePhotoError error.statusText, type

	savePhotoError: (msg, type) =>
		@scope.profile.data[type].uploading = false
		@scope.profile.errors.photo = "Error uploading new photo: #{msg}"

	getMyProfile: (callback=null, setMyProfileOnly=false) =>
		@MyProfile.get().then (profile) =>
			@timeout =>
				@scope.myProfile = profile
				unless setMyProfileOnly is true
					@scope.profile.data = profile
					@scope.profile.form.data =
						displayName: profile.displayName
						username:
							value: profile.username
						location:
							text: profile.location
						bio: profile.bio
					@rootScope.profileDeactivated = profile.deactivated
					@scope.profile.loaded = true
					@buildDigestFromProfileData(@scope.profile.data)
					@reorderDigest()
					callback.call(@) if callback?
			, 750
		, (error) =>
			@scope.profile.loaded = true
			@scope.profile.loadError = "Sorry there has been an error loading this profile: #{error.statusText}"

	getProfile: (id, callback=null) =>
		@Profile.get({id: @element.data('user-id')}).then (profile) =>
			@timeout =>
				@rootScope.isSignedIn = profile.isSignedIn
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
		item = data.recentFollowingSummary
		item.type = 'recentFollowingSummary'
		@scope.profile.digest.push item unless item.sentence.length == 0

		item = data.recentFollowedSummary
		item.type = 'recentFollowedSummary'
		@scope.profile.digest.push item unless item.sentence.length == 0

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
		if @scope.profile.form.edited is true
			@validateProfile @updateProfile
		else
			$('#editProfileFormModal').modal('hide')

	validateProfile: (callback=null) =>
		@scope.profile.errors.displayName = @scope.profile.errors.username = @scope.profile.errors.main = false
		if !@scope.profile.form.data.displayName? or @scope.profile.form.data.displayName.length is 0
			@scope.profile.errors.displayName = "Please choose a Display Name"
		else if !(/^[a-z][a-z\s\-\']*$/i.test(@scope.profile.form.data.displayName))
			@scope.profile.errors.displayName = "Your display name can only contain letters, hyphens, apostrophes and a space"
		else if !@scope.profile.form.data.username.value? or @scope.profile.form.data.username.value.length is 0
			@scope.profile.errors.username = "Please enter a username"
		else if @scope.profile.form.data.username.value.length < 6
			@scope.profile.errors.username = "Your Username must be at least 6 characters long"
		else if !(/^[0-9a-zA-Z_]+$/i.test(@scope.profile.form.data.username.value))
			@scope.profile.errors.username = "Your Username can only contain letters, numbers and an '_'"

		if @scope.profile.errors.displayName or @scope.profile.errors.username
			return false
		else
			if "@#{@scope.profile.form.data.username.value}" is @scope.profile.form.data.originalUsername
				callback.call(@) if callback?
			else
				@http.get("/username-availability?username=@#{@scope.profile.form.data.username.value.toLowerCase()}").then (response) =>
					if response.data is false
						@scope.profile.errors.username = "Username has already been taken"
						return false
					else
						callback.call(@) if callback?

	updateProfile: =>
		@scope.profile.data.originalUsername = "@#{@scope.profile.form.data.username.value.toLowerCase()}"
		profile = new @MyProfile @setProfileData(@scope.profile.form.data)
		profile.update().then (response) =>
			if response.status is 'error'
				@updateProfileError response.message
			else
				@timeout =>
					$('#editProfileFormModal').modal('hide')
					window.location = window.location.pathname
				, 750
		, (error) =>
			@updateProfileError error.statusText

	updateProfileError: (msg) =>
		@scope.profile.errors.main = "Error updating profile: #{msg}"

	setProfileData: (formData) =>
		{
			id: formData.id
			displayName: formData.displayName
			username: "@#{formData.username.value}"
			location:
				value: formData.location.text
				lat: formData.location.lat
				lng: formData.location.lng
				country_code: formData.location.countryCode
			bio: formData.bio
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
		if @rootScope.isSignedIn
			userId = @scope.profile.data.id
			if @scope.profile.data.imFollowing
				@scope.profile.data.imFollowing = false
				@unfollowUser userId, =>
					@cookies.put('ok_to_flash', true)
					window.location.reload()
				, true
			else
				@scope.profile.data.imFollowing = true
				@followUser userId, =>
					@cookies.put('ok_to_flash', true)
					window.location.reload()
				, false, true, =>
					@timeout =>
						@scope.profile.data.imFollowing = false
					, 550
		else
			@requiresSignIn("follow #{@scope.profile.data.displayName}", window.location.pathname)

	toggleFollowUserFromCard: (member) =>
		if @rootScope.isSignedIn
			if member.imFollowing
				member.imFollowing = false
				@unfollowUser member.id, =>
					@flash "You are no longer following <b>#{member.username}</b>"
					if @scope.profile.isMe
						@scope.profile.follows.followings = _.filter @scope.profile.follows.followings, (item) =>
							item.id isnt member.id
						if followerItem = _.findWhere @scope.profile.follows.followers, { id: member.id }
							followerItem.imFollowing = false
					else
						@buildFollowersImFollowingCount()
			else
				member.imFollowing = true
				@followUser member.id, =>
					@flash "You are now following <b>#{member.username}</b>"
					if @scope.profile.isMe
						@scope.profile.follows.followings.push member
					else
						@buildFollowersImFollowingCount()
				, false, false, =>
					@timeout =>
						member.imFollowing = false
					, 550
		else
			@requiresSignIn("follow #{member.displayName}", window.location.pathname)

	openExchangesModal: ($event) =>
		$event.preventDefault()
		@timeout =>
			tpl = $("#allUserExchanges").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#allUserExchangesModal").modal()
		, 350

	reactivateProfile: ($event) =>
		$event.preventDefault() if $event?
		@scope.profile.errors.reactivate = false
		if (!@scope.profile.data.confirmingPassword?) or (@scope.profile.data.confirmingPassword.length is 0)
			@scope.profile.errors.reactivate = "Please enter your account password."
		else
			@http.put("/reactivate?auth=#{@scope.profile.data.confirmingPassword}").then (response) =>
				if response.data.status is 'success'
					@scope.profile.data.deactivated = false
					@rootScope.profileDeactivated = false
					@scope.profile.data.confirmingPassword = ''
					@flash "Your profile has been reactivated"
				else if response.data.status is 'error'
					@scope.profile.errors.reactivate = response.data.message

	cancelEditProfile: ($event) =>
		$event.preventDefault()
		if @scope.profile.form.edited is true
			@confirm "Are you sure you want to discard these changes?", null, =>
				@scope.$apply =>
					$('#editProfileFormModal').modal('hide')
			, "Are you sure?", ['Discard', 'Continue editing']
		else
			$('#editProfileFormModal').modal('hide')

	markFormAsEdited: =>
		@scope.profile.form.edited = true

	selectFollowersTab: ($event, tab) =>
		$event.preventDefault()
		@scope.profile.follows.followersMode = tab

	validateUsernameFromField: =>
		@markFormAsEdited()
		@scope.profile.errors.username = ""
		@validateUsername (result) =>
			@scope.profile.form.data.username.available = result
		, false

	validateUsername: (callback=null, save=false) =>
		url = "/username-availability?username=@#{@scope.profile.form.data.username.value.toLowerCase()}"
		url += "&save=1" if save is true
		@http.get(url).then (response) =>
			if response.data is false
				@scope.profile.errors.username = "Username has already been taken"
				callback.call(@, false) if callback?
				return false
			else
				callback.call(@, true) if callback?
				return true

	autocompleteLocations: ($input) =>
		options =
			types: ['geocode']
			input: $input.val()
			componentRestrictions: {}
			# {country: 'gb'}
		acService = new google.maps.places.AutocompleteService()
		@scope.autocompleteItems = []
		excludeTypes = ['route', 'transit_station', 'point_of_interest', 'premise', 'neighborhood']
		acService.getPlacePredictions options, (predictions) =>
			if _.some(predictions)
				predictions.forEach (prediction) =>
					# console.log prediction
					if _.intersection(prediction.types, excludeTypes).length < 1
						@scope.$apply =>
							@scope.autocompleteItems.push(prediction)

	populateLocation: ($event, prediction) =>
		$event.preventDefault()
		address = prediction.description
		geocoder = new google.maps.Geocoder()
		$target = $($event.currentTarget.innerHTML)
		placeText = "#{$target.find(".main_location_text").text()}, #{$target.find(".secondary_location_text").text()}"
		@scope.profile.form.data.location.text = placeText
		geocoder.geocode { 'address': address }, (results, status) =>
			if status is google.maps.GeocoderStatus.OK
				@scope.$apply =>
					@scope.profile.form.data.location.lat = results[0].geometry.location.lat()
					@scope.profile.form.data.location.lng = results[0].geometry.location.lng()
					results[0].address_components.forEach (component) =>
						if _.contains(component.types, 'country')
							@scope.profile.form.data.location.countryCode = component.short_name
		@scope.autocompleteItems = []

	updateAllSharesWithOpinion: (shareId, action, user) =>
		@updateAllWithOpinion(@scope.profile.ratings.data, shareId, action, user)
		@updateAllWithOpinion(@scope.profile.shares.data, shareId, action, user)
		@updateAllWithOpinion(@scope.profile.exchanges.data, shareId, action, user)
		@updateAllWithOpinion(@scope.profile.opinionActions.data, shareId, action, user)
		@updateAllWithOpinion(@scope.profile.commentActions.data, shareId, action, user)

	openRatingsTab: =>
		angular.element("#activity-ratings-tab").click()

TheArticle.ControllerModule.controller('ProfileController', TheArticle.Profile)