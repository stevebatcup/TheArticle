class TheArticle.Auth extends TheArticle.PageController

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
		@scope.changePassword =
			error: false
			password: ''
			passwordConfirm: ''
			resetToken: @element.find('#user_reset_password_token').val()
			thanks: false
			updating: false
		@scope.signInDetails =
			login:
				value: ''
				error: false
			password:
				value: ''
				error: false
		@bindEvents()
		@bindListeners()

	bindEvents: ->
		@bindCookieAcceptance()

	bindListeners: =>
		@scope.$on 'sign_in_panel_closed', =>
			@closeForgottenPasswordPanel()

	logRegisterFieldFilled: (field) =>
		if field? and @scope.register[field] and @scope.register[field].length > 0
			gtag('event', 'register_field_filled', { 'field': field }) if gtag?

	openRegisterFormFromSignInForm: ($event=null, deviceType='mobile') =>
		$event.preventDefault()
		@openRegisterForm(null, @scope.openedFromAction, deviceType)

	submitRegister: ($event) =>
		$event.preventDefault()
		@scope.register.errors.names = false
		@scope.register.errors.gender = false
		@scope.register.errors.ageBracket = false
		@scope.register.errors.email = false
		@scope.register.errors.password = false
		@scope.register.errors.tandc = false

		error_msg = ''
		if !@scope.register.firstName or @scope.register.firstName.length is 0
			@scope.register.errors.names = error_msg = "Please enter your first name"
		else if !@scope.register.lastName or @scope.register.lastName.length is 0
			@scope.register.errors.names = error_msg = "Please enter your last name"
		else if !@scope.register.gender or @scope.register.gender.length is 0
			@scope.register.errors.gender = error_msg = "Please select your gender"
		else if !@scope.register.ageBracket or @scope.register.ageBracket.length is 0
			@scope.register.errors.ageBracket = error_msg = "Please tell us your age bracket"
		else if !@scope.register.email or @scope.register.email.length is 0
			@scope.register.errors.email = error_msg = "Please enter a valid email address"
		else if !@scope.register.password or @scope.register.password.length is 0
			@scope.register.errors.password = error_msg = "Please enter your new password"
		else if !@scope.register.passwordConfirm or @scope.register.passwordConfirm.length is 0
			@scope.register.errors.password = error_msg = "Please confirm your new password"
		else if @scope.register.password.length < 6
			@scope.register.errors.password = error_msg = "Please make sure your password is at least 6 characters long"
		else if @scope.register.passwordConfirm isnt @scope.register.password
			@scope.register.errors.password = error_msg = "Please make sure your new password and the confirmation match"
		else if !@scope.register.tandc
			@scope.register.errors.tandc = error_msg = "Please confirm that you are over 16 and you agree to our Terms and Conditions"

		if error_msg.length > 0
			gtag('event', 'register_field_error', { 'error': error_msg }) if gtag?
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
			gtag('event', 'sign_up', { 'method': 'Email' }) if gtag?
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
		@http.post("/users/sign_in.json", data).then (response) =>
			if response.data.status is 'success'
				gtag('event', 'login', { 'method': 'Email' }) if gtag?
				window.location.href = response.data.redirect
			else
				@signInError(response.data.status)
		, (response) =>
			@signInError(response.data.status)

	signInError: (msg) =>
		@scope.signInDetails.login.error = msg

	openForgottenPasswordPanel: ($event) =>
		$event.preventDefault()
		@scope.forgottenPassword.show = true

	closeForgottenPasswordPanel: ($event=null) =>
		$event.preventDefault() if $event?
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


	updatePassword: ($event, minimum=10) =>
		$event.preventDefault()
		@scope.changePassword.updating = true
		@scope.changePassword.error = false
		if (!@scope.changePassword.password) or (@scope.changePassword.password.length is 0)
			@scope.changePassword.error = "Please type a new password"
		else if @scope.changePassword.password isnt @scope.changePassword.passwordConfirm
			@scope.changePassword.error = "Please make sure the password entries match"
		else if @scope.changePassword.password.length < minimum
			@scope.changePassword.error = "Please make sure the password is at least #{minimum} characters long"

		if @scope.changePassword.error
			@scope.changePassword.updating = false
			false
		else
			@submitUpdatedPassword()

	submitUpdatedPassword: =>
		data =
			user:
				reset_password_token: @scope.changePassword.resetToken
				password: @scope.changePassword.password
				password_confirmation: @scope.changePassword.passwordConfirm
		@http.patch("/users/password", data).then (response) =>
			@alert response.data.message, "Success", =>
				window.location.href = "/my-home"
		, (response) =>
			@alert response.data.message, "Error updating password"
			@scope.changePassword.updating = true

TheArticle.ControllerModule.controller('AuthController', TheArticle.Auth)