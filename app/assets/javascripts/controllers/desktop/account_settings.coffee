class TheArticle.AccountSettings extends TheArticle.mixOf TheArticle.DesktopPageController, TheArticle.PageTransitions

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$rootElement'
	  '$element'
	  '$timeout'
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
			names: false
			username: false
			email: false
			password: false
			deactivate: false
			reactivate: false
			deleteAccount: false
			genderAndAge: false
		@scope.cleanUsername = ''
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

	watchForCommunicationPreferencesChanges: =>
		angular.forEach @scope.user.communicationPreferences, (value, key) =>
			@scope.$watch "user.communicationPreferences.#{key}", (newVal, oldVal) =>
				if newVal isnt oldVal
					data =
						preferences:
							preference: key
							status: newVal
					@http.put("/communication-preferences", data).then (response) =>
						console.log response

	watchForNotificationSettingsChanges: =>
		angular.forEach @scope.user.notificationSettings, (value, key) =>
			@scope.$watch "user.notificationSettings.#{key}", (newVal, oldVal) =>
				if newVal isnt oldVal
					data =
						settings:
							key: key
							value: newVal
					@http.put("/notification-settings", data).then (response) =>
						if newVal is 'never'
							@checkForEmailNotificationStatusChange()
						else
							@scope.user.emailNotificationStatus = 'On'

	checkForEmailNotificationStatusChange: =>
		allNevers = true
		angular.forEach @scope.user.notificationSettings, (value, key) =>
			allNevers = false if value isnt 'never'
		@scope.user.emailNotificationStatus = if allNevers then 'Off' else 'On'

	backPage: ($event) =>
		$event.preventDefault()
		@rootScope.$broadcast 'page_moving_back'

	getUser: =>
		@AccountSettings.get({me: true}).then (settings) =>
			@scope.user = settings.user
			@scope.cleanUsername = settings.user.username
			@watchForNotificationSettingsChanges()
			@watchForCommunicationPreferencesChanges()
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
		@http.put "/account-settings",
			user: userData
		.then (response) =>
			if response.data.status is 'success'
				successCallback.call(@) if successCallback?
			else if response.data.status is 'error'
				errorCallback.call(@, response.data.message) if errorCallback?

	saveNames: ($event) =>
		$event.preventDefault() if $event?
		@scope.errors.names = false
		if !@scope.user.firstName?
			@scope.errors.names = "Please enter your first name"
		if (!@scope.user.lastName?) and (@scope.errors.names is false)
			@scope.errors.names = "Please enter your last name"
		if @scope.errors.names is false
			@updateUser =>
				@scope.user.fullName = "#{@scope.user.title} #{@scope.user.firstName} #{@scope.user.lastName}"
				@backToPage('account')
				@flash "Your name has been updated"
			,(errorMsg) =>
				@scope.errors.names = errorMsg

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

	saveGenderAndAge: ($event) =>
		$event.preventDefault() if $event?
		@http.put "/account-settings",
			user:
				gender: @scope.user.gender
				age_bracket: @scope.user.ageBracket
		.then (response) =>
			@backToPage('account')
		, (errorMsg) =>
			@scope.errors.genderAndAge = errorMsg

	savePassword: ($event) =>
		$event.preventDefault() if $event?
		@scope.errors.password = false
		if (!@scope.user.confirmingPassword?) or (!@scope.user.confirmingPasswordConfirm?)
			@scope.errors.password = "Please enter the existing password for your account in the first and second boxes above."
		if (@scope.errors.password is false) and (@scope.user.confirmingPassword isnt @scope.user.confirmingPasswordConfirm)
			@scope.errors.password = "Please make sure your existing password and the confirmation match"
		if (@scope.errors.password is false) and ((!@scope.user.password?) or (@scope.user.password.length is 0))
			@scope.errors.password = "Please enter a new password for your account"
		if (@scope.errors.password is false) and (@scope.user.password.length < 6)
			@scope.errors.password = "Please make sure your new password is at least 6 characters long"
		if @scope.errors.password is false
			@updatePassword =>
				alertMsg = "Thanks, your password has been changed."
				@alert alertMsg, "Password changed", =>
					@scope.user.confirmingPassword = ''
					@scope.user.confirmingPasswordConfirm = ''
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
		window.location.href = "/my-profile"

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