class TheArticle.ProfileWizard extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$rootElement'
	  '$timeout'
	  'Profile'
	]

	init: ->
		@scope.user =
			id: @rootElement.data('user-id')
			location:
				value: ''
				error: null
			names:
				displayName:
					value: @rootElement.data('default-display_name')
					error: null
				username:
					value: @rootElement.data('default-username')
					error: null
			selectedExchanges: []

		@scope.exchangesOk = false
		@bindEvents()

	bindEvents: =>
		# @scope.$on 'wizard:stepChanged', (event, args) =>
		# 	console.log(args)

	validateNames: (context) =>
		@scope.user.names.displayName.error = @scope.user.names.username.error = false
		if !@scope.user.names.displayName.value?
			@scope.user.names.displayName.error = "Please choose a Display Name"
		else if !(/^[a-z][a-z\s]*$/i.test(@scope.user.names.displayName.value))
			@scope.user.names.displayName.error = "Your Display Name can only contain letters and a space"
		else if !@scope.user.names.username.value?
			@scope.user.names.username.error = "Please enter a username"
		else if @scope.user.names.username.value.length < 6
			@scope.user.names.username.error = "Your Username must be at least 6 characters long"
		else if !(/^[0-9a-zA-Z_]+$/i.test(@scope.user.names.username.value))
			@scope.user.names.username.error = "Your Username can only contain letters, numbers and an '_'"
		if @scope.user.names.displayName.error or @scope.user.names.username.error
			return false
		else
			return @http.get("/username-availability?username=@#{@scope.user.names.username.value}").then (response) =>
				if response.data is false
					@scope.user.names.username.error = "Username has already been taken"
					return false
				else
					return true

	selectExchange: (selected) =>
		if _.contains(@scope.user.selectedExchanges, selected)
			key = _.findIndex @scope.user.selectedExchanges, (item) =>
				item is selected
			@scope.user.selectedExchanges.splice key, 1
		else
			@scope.user.selectedExchanges.push selected
		@validateExchanges()

	validateExchanges: =>
		@scope.exchangesOk = @scope.user.selectedExchanges.length >= 3

	finishedWizard: =>
		new @Profile(@scope.user).create().then (response) =>
			if response.status is 'error'
				@finishedWizardError(response.error)
			else
				window.location.href = response.redirect
		, (error) =>
			@finishedWizardError(error.statusText)

	finishedWizardError: (msg) =>
		@alert "Sorry there has been an error: #{msg}"

TheArticle.ControllerModule.controller('ProfileWizardController', TheArticle.ProfileWizard)