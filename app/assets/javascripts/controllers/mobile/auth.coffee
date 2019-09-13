class TheArticle.Auth extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$rootElement'
	  '$element'
	  '$timeout'
	  '$ngConfirm'
	  '$compile'
	]

	init: ->
		vars = @getUrlVars()
		@setDefaultHttpHeaders()
		@setCsrfTokenHeaders()
		@scope.register =
			firstName: ''
			lastName: ''
			gender: ''
			ageBracket: ''
			email: ''
			password: ''
			passwordConfirm: ''
			tandc: 0
			joining: false
			errors:
				names: false
				gender: false
				ageBracket: false
				email: false
				password: false
				tandc: false
		@scope.forgottenPassword =
			show: if 'forgotten_password' of vars then true else false
			error: false
			email: ''
			thanks: false
		@scope.signInDetails =
			login:
				value: ''
				error: false
			password:
				value: ''
				error: false
		@bindEvents()

	bindEvents: ->
		@bindCookieAcceptance()

	submitRegister: ($event) =>
		$event.preventDefault()
		@scope.register.errors.names = false
		@scope.register.errors.gender = false
		@scope.register.errors.ageBracket = false
		@scope.register.errors.email = false
		@scope.register.errors.password = false
		@scope.register.errors.tandc = false

		if !@scope.register.firstName or @scope.register.firstName.length is 0
			@scope.register.errors.names = "Please enter your first name"
		else if !@scope.register.lastName or @scope.register.lastName.length is 0
			@scope.register.errors.names = "Please enter your last name"
		else if !@scope.register.gender or @scope.register.gender.length is 0
			@scope.register.errors.gender = "Please select your gender"
		else if !@scope.register.ageBracket or @scope.register.ageBracket.length is 0
			@scope.register.errors.ageBracket = "Please tell us your age bracket"
		else if !@scope.register.email or @scope.register.email.length is 0
			@scope.register.errors.email = "Please enter a valid email address"
		else if !@scope.register.password or @scope.register.password.length is 0
			@scope.register.errors.password = "Please enter your new password"
		else if !@scope.register.passwordConfirm or @scope.register.passwordConfirm.length is 0
			@scope.register.errors.password = "Please confirm your new password"
		else if @scope.register.password.length < 6
			@scope.register.errors.password = "Please make sure your password is at least 6 characters long"
		else if @scope.register.passwordConfirm isnt @scope.register.password
			@scope.register.errors.password = "Please sure your new password and the confirmation match"
		else if !@scope.register.tandc
			@scope.register.errors.tandc = "Please confirm that you are over 16 and you agree to our Terms and Conditions"

		if @scope.register.errors.names or @scope.register.errors.gender or @scope.register.errors.ageBracket or @scope.register.errors.email or @scope.register.errors.password or @scope.register.errors.tandc
			return false
		else
			@scope.register.joining = true
			@http.get("/email-availability?email=#{@scope.register.email}").then (response) =>
				if response.data is true
					@sendRegistration()
				else
					@scope.register.joining = false
					@scope.register.errors.email = "Sorry that email address already exists."

	sendRegistration: =>
		url = $('form#new_user').attr('action')
		@postJSON url,
			'g-recaptcha-response': $('#g-recaptcha-response').val()
			user:
				first_name: @scope.register.firstName
				last_name: @scope.register.lastName
				gender: @scope.register.gender
				age_bracket: @scope.register.ageBracket
				email: @scope.register.email
				password: @scope.register.password
		, (response) =>
			gtag('event', 'sign_up', { 'signUpMethod': 'Email' }) if gtag?
			window.location.href = response.redirect_to
		, (response) =>
			@scope.$apply =>
				@scope.register.joining = false
				@scope.register.errors.tandc = response.message

	signIn: ($event) =>
		$event.preventDefault()
		@scope.signInDetails.login.error = false
		@scope.signInDetails.password.error = false

		if @scope.signInDetails.login.value.length is 0
			@scope.signInDetails.login.error = "Please enter your email address or username"
		else if @scope.signInDetails.password.value.length is 0
			@scope.signInDetails.password.error = "Please enter your password"

		if @scope.signInDetails.login.error or @scope.signInDetails.password.error
			return false
		else
			return @submitSignIn()

	submitSignIn: =>
		if @scope.signInDetails.login.value.indexOf('@') > 1
			login = @scope.signInDetails.login.value
		else
			if login = @scope.signInDetails.login.value.indexOf('@') is -1
				login = "@#{login = @scope.signInDetails.login.value}"
			else
				login = @scope.signInDetails.login.value
		data =
			user:
				login: login
				password: @scope.signInDetails.password.value
		@http.post("/users/sign_in", data).then (response) =>
			gtag('event', 'login', { 'method': 'Email' }) if gtag?
			window.location.href = response.data.redirect
		, (response) =>
			@scope.signInDetails.login.error = response.data.status

	openForgottenPasswordPanel: ($event) =>
		$event.preventDefault()
		@scope.forgottenPassword.show = true

	closeForgottenPasswordPanel: ($event) =>
		$event.preventDefault()
		@scope.forgottenPassword.show = false

	resetPassword: ($event) =>
		$event.preventDefault()
		@scope.forgottenPassword.error = false

		if (!@scope.forgottenPassword.email) or (@scope.forgottenPassword.email.length is 0)
			@scope.forgottenPassword.error = "Please enter your email address"

		if @scope.forgottenPassword.error
			return false
		else
			return @submitResetPassword()

	submitResetPassword: =>
		data =
			user:
				email: @scope.forgottenPassword.email
		@http.post("/users/password", data).then (response) =>
			@scope.forgottenPassword.thanks = response.data.message
		, (response) =>
			@scope.forgottenPassword.error = response.data.message

TheArticle.ControllerModule.controller('AuthController', TheArticle.Auth)