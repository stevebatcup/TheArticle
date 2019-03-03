class TheArticle.PageController extends TheArticle.NGController
	constructor: ->
		super
		@showCookieNotice() if $('body').hasClass('show_cookie_notice')

	hasAds: ->
		$('#ads_top').length > 0

	flash: (msg, action=null) =>
		$.notifyClose('bottom-center')
		$.notify({
			message: msg
		},
		{
			element: 'body',
			allow_dismiss: false,
			newest_on_top: true,
			placement: {
				from: "bottom",
				align: "center"
			},
			offset: 0,
			spacing: 20,
			delay: 8000,
			timer: 1000,
			animate: {
				enter: 'animated fadeInUp',
				exit: 'animated fadeOutDown'
			},
			template: '<div data-notify="container" class="col-xs-11 col-sm-3 col-md-5 col-lg-6 alert bg-dark text-white" role="alert">' +
					'<div class="d-flex justify-content-between">' +
					'<div>' +
					'<button type="button" aria-hidden="true" class="close" data-notify="dismiss">×</button>' +
					'<span data-notify="icon"></span> ' +
					'<span data-notify="title">{1}</span> ' +
					'<span data-notify="message">{2}</span>' +
					'<div class="progress" data-notify="progressbar">' +
						'<div class="progress-bar progress-bar-{0}" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;"></div>' +
					'</div>' +
					'</div>' +
					'</div>' +
				'</div>'
		})

	showCookieNotice: =>
		$('#cookie-notice').show()

	isDevelopment: =>
		$('body').hasClass('development')

	isStaging: =>
		$('body').hasClass('staging')

	isProduction: =>
		$('body').hasClass('production')

	alert: (msg, title='Error', callback=null, buttonText='OK') =>
		alertBox = @ngConfirm
			title: title
			content: msg
			scope: @scope
			buttons:
				successBtn:
					text: buttonText
					btnClass: 'btn-info'
					action: =>
						setTimeout =>
							callback.call(@) if callback?
						, 150

	confirm: (msg, success, cancel=null, title='Are you sure?', buttons=null) =>
		confirmBox = @ngConfirm
			title: title
			content: msg
			scope: @scope
			closeIcon: true,
			closeIconClass: 'fas fa-times'
			buttons:
				cancelBtn:
					text: buttons[0]
					btnClass: 'btn-danger'
					action: =>
						cancel.call(@) if cancel?
						confirmBox.close()
				successBtn:
					text: buttons[1]
					btnClass: 'btn-success'
					action: success

	postJSON: (url, data, successCallback=null, errorCallback=null) =>
		$.ajax
			url: url,
			type: 'POST'
			dataType: 'json'
			data: data
			success: (response) =>
				if response.status is 'success'
					successCallback.call(@, response) if successCallback?
				else
					errorCallback.call(@, response) if errorCallback?
			error: (response) =>
				errorCallback.call(@, response) if errorCallback?

	trustSrc: (src) =>
		src

	trustHtml: (html) =>
		html

	bindCookieAcceptance: =>
		$('#cn-accept-cookie').on 'click', (e) =>
			$.getJSON '/cookie-acceptance', (response) =>
				if response.status is 'success'
					$('#cookie-notice').fadeOut()
					$('body').removeClass('show_cookie_notice')
				else
					@cookieAcceptanceError()
			.fail (error) =>
				@cookieAcceptanceError()

	cookieAcceptanceError: =>
		@alert "Sorry there has been an error. Please try again.", "Error"

	bindContactForm: =>
		$form = $('#contact_form')
		$('#send_message', $form).on 'click', (e) =>
			e.preventDefault()
			$('p#contact_error', $form).text('').hide()
			error = false
			$('.has_error', $form).removeClass('has_error')
			if $form.find('input[name=first_name]').val().length is 0
				$form.find('input[name=first_name]').addClass('has_error')
				error = "Please fill in your first name"
			if $form.find('input[name=last_name]').val().length is 0
				$form.find('input[name=last_name]').addClass('has_error')
				error = "Please fill in your last name" unless error
			if !@isValidEmailAddress $form.find('input[name=email]').val()
				$form.find('input[name=email]').addClass('has_error')
				error = "Please fill in a valid email address" unless error
			if $form.find('input[name=subject]').val().length is 0
				$form.find('input[name=subject]').addClass('has_error')
				error = "Please fill in a subject for your message" unless error
			if $form.find('textarea[name=message]').val().length is 0
				$form.find('textarea[name=message]').addClass('has_error')
				error = "Please fill in the message field" unless error

			if error
				$('p#contact_error', $form).text(error).show()
			else
				@postJSON "/contact",
					first_name: $form.find('input[name=first_name]').val()
					last_name: $form.find('input[name=last_name]').val()
					email: $form.find('input[name=email]').val()
					subject: $form.find('input[name=subject]').val()
					message: $form.find('textarea[name=message]').val()
				, (response) =>
					$('body, html').scrollTop(0)
					msg = "Thank you for your message. A member of the team will be in touch with you shortly."
					$('.contact_ready').hide()
					$('#contact_success').text(msg).show()
				, (response) =>
					msg = "Sorry there has been an error sending your message, please try again."
					$('p#contact_error', $form).text(msg).show()

	bindSearchFilters: =>
		$('input[name=search_filter]', 'form.filter_list_form').on 'keyup', (e) =>
			if e.keyCode is 13
				e.preventDefault()
				return false
			term = $('input[name=search_filter]').val().toLowerCase()
			$list = $('form.filter_list_form').parent().find('.filter_list')
			found = 0
			$list.find('article').each (index, article) =>
				targetText = $(article).find('.filter_target').text().toLowerCase()
				if targetText.indexOf(term) != -1
					$(article).show()
					found += 1
				else
					$(article).hide()
			if found is 0
				$('p.filter_none_found').show()
			else
				$('p.filter_none_found').hide()

	bindBlockClicks: =>
		$(document).on 'click', '.block_click', (e) =>
			$clicked = $(e.target)
			@blockClick $clicked, e

	blockClick: ($clicked, e) =>
		if $clicked.prop('tagName') isnt "A" and $clicked.parent().prop('tagName') isnt "A"
			e.preventDefault()
			if $clicked.prop('tagName') isnt "BUTTON" and $clicked.parent().prop('tagName') isnt "BUTTON"
				if $clicked.prop('tagName') is "DIV" and $clicked.data('href')
					link = $clicked.data('href')
				else
					link = $clicked.closest('[data-href]').data('href')
				window.location.href = link unless link is '#'

	truncateNearestWord: (str, maxLen, separator = ' ') =>
		if (str.length <= maxLen)
			return str
		else
			return str.substr 0, str.lastIndexOf(separator, maxLen)

	isValidEmailAddress: (email) =>
		return false if email.length is 0
		pattern = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
		return pattern.test email

	isValidUrl: (value) =>
		return /^(?:(?:(?:https?|ftp):)?\/\/)(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:[/?#]\S*)?$/i.test(value)

	getUrlVars: =>
		vars = {}
		parts = window.location.href.replace /[?&]+([^=&]+)=([^&]*)/gi, (m,key,value) ->
			vars[key] = value
		return vars

	setDefaultHttpHeaders: ->
		@http.defaults.headers.common['Accept'] = 'application/json'
		@http.defaults.headers.common['Content-Type'] = 'application/json'

	setCsrfTokenHeaders: ->
		@http.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')

	followUser: (userId, callback, from_suggestion=false, showFlash=false) =>
		data = { id: userId, from_suggestion: from_suggestion }
		data['set_flash'] = 1 if showFlash
		@http.post("/user_followings", data).then (response) =>
			if response.data.status is 'success'
				callback.call(@)
			else if response.data.status is 'error'
				@alert response.data.message, "Error following user"

	unfollowUser: (userId, callback, showFlash=false) =>
		url = "/user_followings/#{userId}"
		url += "?set_flash=1" if showFlash
		@http.delete(url).then (response) =>
			callback.call(@)

	followExchange: (exchangeId, callback, showFlash=false) =>
		data = { id: exchangeId }
		data['set_flash'] = 1 if showFlash
		@http.post("/user_exchanges", data).then (response) =>
			callback.call(@, response)

	unfollowExchange: (exchangeId, callback, showFlash=false) =>
		url = "/user_exchanges/#{exchangeId}"
		url += "?set_flash=1" if showFlash
		@http.delete(url).then (response) =>
			if response.data.status is 'success'
				callback.call(@, response)
			else
				@alert response.data.message, "Error unfollowing exchange"

	toggleFollowExchangeFromCard: (exchange, $event) =>
		$event.preventDefault()
		if exchange.imFollowing
			@unfollowExchange exchange.id, =>
				exchange.imFollowing = false
				@cookies.put('ok_to_flash', true)
				window.location.reload()
			, true
		else
			@followExchange exchange.id, =>
				exchange.imFollowing = true
				@cookies.put('ok_to_flash', true)
				window.location.reload()
			, true

	openRegisterForm: ($event=null) =>
		$event.preventDefault() if $event
		$('[data-dismiss=modal]', '#signinBoxModal').click()
		$('[data-dismiss=modal]', '#forgottenPasswordBoxModal').click()
		@timeout =>
			tpl = $("#registerBox").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#registerBoxModal").modal()
		, 350

	requiresSignIn: (action) =>
		@openSigninForm()
		@scope.authMessage = "You must be signed in to #{action}"

	openSigninForm: ($event=null) =>
		$event.preventDefault() if $event
		@scope.authMessage = ""
		$('[data-dismiss=modal]', '#registerBoxModal').click()
		$('[data-dismiss=modal]', '#forgottenPasswordBoxModal').click()
		@timeout =>
			tpl = $("#signinBox").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#signinBoxModal").modal()
		, 350

	openForgottenPasswordForm: ($event) =>
		$event.preventDefault()
		$('[data-dismiss=modal]', '#signinBoxModal').click()
		$('[data-dismiss=modal]', '#registerBoxModal').click()
		@timeout =>
			tpl = $("#forgottenPasswordBox").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#forgottenPasswordBoxModal").modal()
		, 350

	getDocumentHeight: ->
		scroll = Math.max(document.body.scrollHeight, document.documentElement.scrollHeight)
		offset = Math.max(document.body.offsetHeight, document.documentElement.offsetHeight)
		client = Math.max(document.body.clientHeight, document.documentElement.clientHeight)
		Math.max(scroll, offset, client)

	disableBackButton: =>
		history.pushState null, null, location.href
		window.onpopstate = =>
			history.go(1)

	initRandExchangeIndex: =>
		maximum = 12
		minimum = 1
		Math.floor(Math.random() * (maximum - minimum + 1)) + minimum;
