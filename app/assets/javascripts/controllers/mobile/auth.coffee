
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
		data =
			user:
				login: @scope.signInDetails.login.value
				password: @scope.signInDetails.password.value
		@http.post("/users/sign_in", data).then (response) =>
			window.location.href = "/my-home"
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