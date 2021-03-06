class TheArticle.PageController extends TheArticle.NGController
	constructor: ->
		super
		@showCookieNotice() if $('body').hasClass('show_cookie_notice')
		@showTestingEnvironmentInterstitial() if $('body').hasClass('show_testing_interstitial')

	hasAds: ->
		$('#ads_top').length > 0

	flash: (msg, action=null) =>
		delayTime = 8000
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
			delay: delayTime,
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

	trustAsHtml: (html) =>
		@sce.trustAsHtml(html)

	bindCookieAcceptance: =>
		$('#cn-accept-cookie').on 'click', (e) =>
			e.preventDefault()
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
			if $form.find('textarea[name=catchme]').val().length > 0
				window.location.href = 'https://www.google.com/search?q=spambot+spambot+spambot'
			else
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
		$clickedTag = $clicked.prop('tagName')
		$parent = $clicked.parent()
		$parentTag = $parent.prop('tagName')
		if $clickedTag isnt "A" and $parentTag isnt "A" and $clickedTag isnt "svg" and $parentTag isnt "svg"
			e.preventDefault()
			if $clickedTag isnt "BUTTON" and $parentTag isnt "BUTTON"
				if $clickedTag is "DIV" and $clicked.data('href')
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

	followUser: (userId, callback=null, from_suggestion=false, showFlash=false, errorCallback=null) =>
		data = { id: userId, from_suggestion: from_suggestion }
		data['set_flash'] = 1 if showFlash
		@http.post("/user_followings", data).then (response) =>
			if response.data.status is 'success'
				callback.call(@, response) if callback?
			else if response.data.status is 'error'
				@alert response.data.message, "Error following user"
				errorCallback.call(@) if errorCallback?

	unfollowUser: (userId, callback=null, showFlash=false) =>
		url = "/user_followings/#{userId}"
		url += "?set_flash=1" if showFlash
		@http.delete(url).then (response) =>
			callback.call(@, response) if callback?

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
		isMobileApp = @mobileAppDetected()
		if exchange.imFollowing
			@unfollowExchange exchange.id, (response) =>
				exchange.imFollowing = false
				if isMobileApp
					@flash response.data.message
				else
					@cookies.put('ok_to_flash', true)
					window.location.reload()
			, !isMobileApp
		else
			@followExchange exchange.id, (response) =>
				exchange.imFollowing = true
				if isMobileApp
					@flash response.data.message
				else
					@cookies.put('ok_to_flash', true)
					window.location.reload()
			, !isMobileApp

	openRegisterForm: ($event=null, from='header', deviceType='mobile') =>
		$event.preventDefault() if $event?
		if @isFacebookInAppBrowser()
			window.location.href = "/users/sign_up"
		else
			if 'articleRegisterInterstitialTimeout' of @scope
				@timeout.cancel(@scope.articleRegisterInterstitialTimeout)
			$('[data-dismiss=modal]', '#signinBoxModal').click()
			$('[data-dismiss=modal]', '#forgottenPasswordBoxModal').click()
			if gtag?
				console.log "registration form was opened from '#{from}'" if console?
				gtagData =
					from: from
					url: window.location.pathname
					deviceType: deviceType
				gtag('event', 'open_register_form', gtagData)
			@timeout =>
				$("#registerBoxModal").modal()
			, 350

	requiresSignIn: (action, returnTo=null) =>
		@setReturnLocation(returnTo) if returnTo?
		@openSigninForm(null, action)
		@scope.authMessage = "You must be signed in to #{action}"

	openSigninForm: ($event=null, forcedFromAction=null) =>
		$event.preventDefault() if $event?
		if @isFacebookInAppBrowser()
			window.location.href = "/users/sign_in"
		else
			@scope.authMessage = ""
			$('[data-dismiss=modal]', '#registerBoxModal').click()
			$('[data-dismiss=modal]', '#forgottenPasswordBoxModal').click()
			@timeout =>
				unless 'signinFormContent' of @scope
					@scope.openedFromAction = @underscoreiseString(forcedFromAction) if forcedFromAction?
					tpl = $("#signinBox").html().trim()
					@scope.signinFormContent = @compile(tpl)(@scope)
				$('body').append @scope.signinFormContent
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

	showTestingEnvironmentInterstitial: =>
		if $('#testDomainInterstitial').length
			tpl = $("#testDomainInterstitial").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#testDomainInterstitialModal").modal()

	acceptTestingEnvironmentInterstitial: ($event) =>
		$event.preventDefault()
		$.getJSON '/accept-testing-environment', (response) =>
			if response.status is 'success'
				$("#testDomainInterstitialModal").modal('hide')
				$('body').removeClass('show_testing_interstitial')
			else
				@testingEnvironmentInterstitialAcceptanceError()
		.fail (error) =>
			@testingEnvironmentInterstitialAcceptanceError()

	testingEnvironmentInterstitialAcceptanceError: =>
		alert "Sorry there has been an error. Please try again.", "Error"

	openFeedbackForm: ($event) =>
		$event.preventDefault()
		tpl = $("#testDomainFeedbackForm").html().trim()
		$content = @compile(tpl)(@scope)
		$('body').append $content
		$("#testDomainFeedbackFormModal").modal()

	showRegistrationInterstitial: =>
		tpl = $("#registerInterstitial").html().trim()
		$content = @compile(tpl)(@scope)
		$('body').append $content
		$("#registerInterstitialModal").modal
			backdrop: 'static'
			keyboard: false

	showDonationInterstitial: =>
		@logDonationInterstitialImpression()
		tpl = $("#donationInterstitial").html().trim()
		$content = @compile(tpl)(@scope)
		$('body').append $content
		$("#donationInterstitialModal").modal
			backdrop: 'static'
			keyboard: false

	logDonationInterstitialImpression: =>
		@http.get("/donate-interstitial-impression")


	getCurrentWord: ($textbox) =>
		stopCharacters = [' ', '\n', '\r', '\t']
		start = $textbox[0].selectionStart
		end = $textbox[0].selectionEnd
		text = $textbox.val()
		while start > 0
			if stopCharacters.indexOf(text[start-1]) is -1
				start--
			else
				break
		start++
		while end < text.length
			if stopCharacters.indexOf(text[end-1]) is -1
				end++
			else
				break
		currentWord = text.substr(start-1, end - (start-1))

	setUserTagging: ($textbox) =>
		word = @getCurrentWord($textbox)
		if word.match /^\@(.)+/
			@http.get("/profile/search-by-username/#{word}").then (response) =>
				console.log response.results if console?

	ignoreSuggestedMember: (memberId, callback=null) =>
		@http.post("/ignore-suggestion", {id: memberId}).then (response) =>
			if response.data.status is 'success'
				callback.call(@) if callback?

	setReturnLocation: (url) =>
		@http.post("/set-stored-location", {return_to: url})

	getUserAgent: =>
		navigator.userAgent || navigator.vendor || window.opera

	isFacebookInAppBrowser: =>
		ua = @getUserAgent()
		ua.indexOf("FBAN") > -1 || ua.indexOf("FBAV") > -1

	underscoreiseString: (str) =>
		str.trim().toLowerCase().replace(/[^a-zA-Z0-9 -]/, "").replace(/\s/g, "_")

	saveMessagingDeviceToken: =>
		prom = (currentToken) =>
			# console.log currentToken
			if currentToken
				# console.log('Got FCM device token:', currentToken)
				@postJSON "/push_registrations", {subscription: currentToken}, =>
					console.log "push token already registered: #{currentToken}" if console?
			else
				# Need to request permissions to show notifications.
				@requestNotificationsPermissions()
		firebase.messaging().getToken().then prom.bind(@)
		.catch (error) ->
			console.error('Unable to get messaging tokens.', error)

	requestNotificationsPermissions: =>
		prom = =>
			# Notification permission granted.
			@saveMessagingDeviceToken()
		# console.log('Requesting notifications permission...')
		firebase.messaging().requestPermission().then prom.bind(@)
		.catch (error) ->
			console.error('Unable to get permission to notify.', error)

	properCountryCode: (code) =>
		if code.toLowerCase() is 'gb' then 'UK' else code.toUpperCase()

	mobileAppDetected: =>
		!!$('body').data('mobile-app')
