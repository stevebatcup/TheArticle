class TheArticle.AccountSettings extends TheArticle.mixOf TheArticle.DesktopPageController, TheArticle.PageTransitions

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$rootElement'
	  '$element'
	  '$timeout'
	  '$interval'
	  '$compile'
	  '$ngConfirm'
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
		@scope.errors =
			yourDetails: false
			username: false
			email: false
			password: false
			deactivate: false
			reactivate: false
			deleteAccount: false
		@scope.cleanUsername = ''
		@scope.usernameAvailable = false
		@scope.user = {}
		@scope.userDup = {}
		@scope.profile = {}
		@resetContainerHeight()
		@bindEvents()
		@getUser()

		@scope.followCounts =
			followers: 0
			followings: 0
			connections: 0
		@updateMyFollowCounts()
		@interval =>
			@updateMyFollowCounts()
		, 10000

		vars = @getUrlVars()
		if 'reactivate' of vars
			@forwardToPage(null, 'manage_profile')
			@timeout =>
				@forwardToPage(null, 'reactivate_profile')
			, 400


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

	watchForCommunicationPreferencesChanges: =>
		angular.forEach @scope.user.communicationPreferences, (value, key) =>
			@scope.$watch "user.communicationPreferences.#{key}", (newVal, oldVal) =>
				if newVal isnt oldVal
					data =
						preferences:
							preference: key
							status: newVal
					@http.put("/communication-preferences", data).then (response) =>
						console.log(response) if console?

	backPage: ($event) =>
		$event.preventDefault()
		@rootScope.$broadcast 'page_moving_back'

	getUser: =>
		@AccountSettings.get({me: true}).then (settings) =>
			@scope.user = settings.user
			@scope.userDup = _.clone(settings.user)
			@scope.cleanUsername = settings.user.username
			@watchForCommunicationPreferencesChanges()
			@getProfile()

	getConnects: =>
		unless @scope.connects.loaded
			@http.get("/connects").then (response) =>
				@scope.connects.data = response.data.connects
				@resetContainerHeight()
				@timeout =>
					@scope.connects.loaded = true
					@resetContainerHeight()
				, 900

	getMutes: =>
		unless @scope.mutes.loaded
			@http.get("/mutes").then (response) =>
				@scope.mutes.data = response.data.mutes
				@resetContainerHeight()
				@timeout =>
					@scope.mutes.loaded = true
					@resetContainerHeight()
				, 900

	getBlocks: =>
		unless @scope.blocks.loaded
			@http.get("/blocks").then (response) =>
				@scope.blocks.data = response.data.blocks
				@resetContainerHeight()
				@timeout =>
					@scope.blocks.loaded = true
					@resetContainerHeight()
				, 900

	unmute: (item, $event) =>
		$event.preventDefault()
		@http.delete("/mutes/#{item.id}").then (response) =>
			@scope.mutes.data = _.select @scope.mutes.data, (mute) =>
				mute.id isnt item.id
			@flash "You have unmuted <b>#{item.username}</b>"

	unblock: (item, $event) =>
		$event.preventDefault()
		@http.delete("/blocks/#{item.id}").then (response) =>
			@scope.blocks.data = _.select @scope.blocks.data, (block) =>
				block.id isnt item.id
			@flash "You have unblockd <b>#{item.username}</b>"

	toggleFollowUserFromCard: (member) =>
		@unfollowUser member.id ,=>
			@scope.connects.data = _.select @scope.connects.data, (connect) =>
				connect.id isnt member.id

	getProfile: =>
		@Profile.get({id: @scope.user.id}).then (profile) =>
			@scope.profile = profile

	updateUser: (successCallback=null, errorCallback=null) =>
		userData =
			title: @scope.user.title
			first_name: @scope.user.firstName
			last_name: @scope.user.lastName
			username: @scope.user.originalUsername
			gender: @scope.user.gender
			age_bracket: @scope.user.ageBracket
		@http.put "/account-settings",
			user: userData
		.then (response) =>
			if response.data.status is 'success'
				successCallback.call(@) if successCallback?
			else if response.data.status is 'error'
				errorCallback.call(@, response.data.message) if errorCallback?

	cancelYourDetails: ($event) =>
		$event.preventDefault() if $event?
		@scope.user.firstName = @scope.userDup.firstName
		@scope.user.lastName = @scope.userDup.lastName
		@scope.user.gender = @scope.userDup.gender
		@scope.user.ageBracket = @scope.userDup.ageBracket
		@backToPage('account', null)

	saveYourDetails: ($event) =>
		$event.preventDefault() if $event?
		@scope.errors.yourDetails = false
		if !@scope.user.firstName?
			@scope.errors.yourDetails = "Please enter your first name"
		if (!@scope.user.lastName?) and (@scope.errors.yourDetails is false)
			@scope.errors.yourDetails = "Please enter your last name"
		if @scope.errors.yourDetails is false
			@updateUser =>
				@scope.user.fullName = "#{@scope.user.firstName} #{@scope.user.lastName}"
				@backToPage('account')
				@flash "Your details have been updated"
			,(errorMsg) =>
				@scope.errors.yourDetails = errorMsg

	validateUsernameFromField: =>
		@scope.errors.username = ""
		@validateUsername (result) =>
			@scope.usernameAvailable = result
		, false

	validateUsername: (callback=null, save=false) =>
		url = "/username-availability?username=@#{@scope.user.username}"
		url += "&save=1" if save is true
		@http.get(url).then (response) =>
			if response.data is false
				@scope.errors.username = "Username has already been taken"
				callback.call(@, false) if callback?
				return false
			else
				callback.call(@, true) if callback?
				return true

	cancelUsername: ($event) =>
		$event.preventDefault() if $event?
		@scope.errors.username = false
		@scope.usernameAvailable = false
		@scope.user.username = @scope.userDup.username
		@backToPage('account', null)

	saveUsername: ($event) =>
		$event.preventDefault() if $event?
		@scope.errors.username = false
		if !@scope.user.username?
			@scope.errors.username = "Please enter a unique username"
		else
			if @scope.user.username is @scope.cleanUsername
				@backToPage('account')
			else
				return @http.get("/username-availability?username=@#{@scope.user.username}").then (response) =>
					if response.data is false
						@scope.errors.username = "Username has already been taken"
					else
						@scope.user.originalUsername = "@#{@scope.user.username}"
						@updateUser =>
							@backToPage('account')
							@flash "Your username has been updated"
						,(errorMsg) =>
							@scope.errors.username = errorMsg

	cancelEmail: ($event) =>
		$event.preventDefault() if $event?
		@scope.errors.email = false
		@scope.user.email = @scope.userDup.email
		@backToPage('account', null)

	saveEmail: ($event) =>
		$event.preventDefault() if $event?
		@scope.errors.email = false
		if !@scope.user.email?
			@scope.errors.email = "Please provide a valid email address"
		if (@scope.errors.email is false) and !@isValidEmailAddress(@scope.user.email)
			@scope.errors.email = "Please provide a valid email address"
		if @scope.errors.email is false
			if @scope.user.email is @scope.user.cleanEmail
				@backToPage('account')
			else
				@updateEmail =>
					alertMsg = "Your request to change your email address has been received and an email has been sent to <b>#{@scope.user.email}</b>.
					To complete this change request, please verify your new email address by clicking on the link in that email"
					@alert alertMsg, "Email address change request", =>
						@scope.user.email = @scope.userDup.email
						@backToPage('account')
				, (errorMsg) =>
					@scope.errors.email = errorMsg

	updateEmail: (successCallback=null, errorCallback=null) =>
		@http.put "/update-email",
			user:
				email: @scope.user.email
		.then (response) =>
			if response.data.status is 'success'
				successCallback.call(@) if successCallback?
			else if response.data.status is 'error'
				errorCallback.call(@, response.data.message) if errorCallback?

	saveEmailNotifications: ($event) =>
		$event.preventDefault() if $event?
		angular.forEach @scope.user.notificationSettings, (value, key) =>
			data =
				settings:
					key: key
					value: value
			@http.put("/notification-settings", data).then (response) =>
				if value is 'never'
					@checkForEmailNotificationStatusChange()
				else
					@scope.user.emailNotificationStatus = 'On'
		@backToPage('notifications')

	checkForEmailNotificationStatusChange: =>
		allNevers = true
		angular.forEach @scope.user.notificationSettings, (value, key) =>
			allNevers = false if value isnt 'never'
		@scope.user.emailNotificationStatus = if allNevers then 'Off' else 'On'

	savePassword: ($event) =>
		$event.preventDefault() if $event?
		@scope.errors.password = false
		if (!@scope.user.confirmingPassword?) or (@scope.user.confirmingPassword.length is 0)
			@scope.errors.password = "Please enter the existing password for your account in the first box above."
		if (@scope.errors.password is false) and ((!@scope.user.password?) or (@scope.user.password.length is 0))
			@scope.errors.password = "Please enter a new password for your account"
		if (@scope.errors.password is false) and (@scope.user.password isnt @scope.user.newPasswordConfirmation)
			@scope.errors.password = "Please make sure your new password and the confirmation match"
		if (@scope.errors.password is false) and (@scope.user.password.length < 6)
			@scope.errors.password = "Please make sure your new password is at least 6 characters long"
		if @scope.errors.password is false
			@updatePassword =>
				alertMsg = "Thanks, your password has been changed."
				@alert alertMsg, "Password changed", =>
					@scope.user.confirmingPassword = ''
					@scope.user.newPasswordConfirmation = ''
					@scope.user.password = ''
					@backToPage('account')
			, (errorMsg) =>
				@scope.errors.password = errorMsg

	updatePassword: (successCallback=null, errorCallback=null) =>
		@http.put "/update-password",
			user:
				existing_password: @scope.user.confirmingPassword
				new_password: @scope.user.password
		.then (response) =>
			if response.data.status is 'success'
				successCallback.call(@) if successCallback?
			else if response.data.status is 'error'
				errorCallback.call(@, response.data.message) if errorCallback?

	deleteAccount: ($event) =>
		$event.preventDefault() if $event?
		@scope.errors.deleteAccount = false
		@http.delete("/delete-account?auth=#{@scope.user.confirmingPassword}").then (response) =>
			if response.data.status is 'success'
				@timeout =>
					window.location.href = "/?account_deleted=1"
				, 1000
			else if response.data.status is 'error'
				@scope.errors.deleteAccount = response.data.message

	deactivateProfile: ($event) =>
		$event.preventDefault() if $event?
		@scope.errors.deactivate = false
		@http.put("/deactivate?auth=#{@scope.user.confirmingPassword}").then (response) =>
			if response.data.status is 'success'
				@scope.user.profileDeactivated = true
				@flash "Your profile has been deactivated"
				@timeout =>
					@resetPages()
				, 500
			else if response.data.status is 'error'
				@scope.errors.deactivate = response.data.message

	editProfile: ($event) =>
		$event.preventDefault() if $event?
		window.location.href = "/my-profile?panel=edit_profile"

	reactivateProfile: ($event) =>
		$event.preventDefault() if $event?
		@scope.errors.reactivate = false
		@http.put("/reactivate?auth=#{@scope.user.confirmingPassword}").then (response) =>
			if response.data.status is 'success'
				@scope.user.profileDeactivated = false
				@flash "Your profile has been reactivated"
				@timeout =>
					@resetPages()
				, 500
			else if response.data.status is 'error'
				@scope.errors.reactivate = response.data.message

TheArticle.ControllerModule.controller('AccountSettingsController', TheArticle.AccountSettings)