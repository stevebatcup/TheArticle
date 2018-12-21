class TheArticle.PageController extends TheArticle.NGController
	constructor: ->
		super
		@showCookieNotice() if $('body').hasClass('show_cookie_notice')

	showCookieNotice: =>
		$('#cookie-notice').show()

	isDevelopment: =>
		$('body').hasClass('development')

	isStaging: =>
		$('body').hasClass('staging')

	isProduction: =>
		$('body').hasClass('production')

	alert: (msg, title, callback=null) =>
		alert msg, title, callback

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
		@sce.trustAsResourceUrl(src)

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

	bindJoinForm: =>
		$("#join_form_modal").on 'shown.bs.modal', =>
			$('.wrapper, #ads_top').hide()

		$("#join_form_modal").on 'hide.bs.modal', =>
			$('.wrapper, #ads_top').show()

		$form = $('#join_form')
		$('#join_button', $form).on 'click', (e) =>
			e.preventDefault()
			$('p#form_error', $form).text('').hide()
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
			if !$form.find('input[name=tandcs]').is(':checked')
				$form.find('input[name=tandcs]').parent().addClass('has_error')
				error = "Please agree to our terms and conditions before proceeding" unless error

			if error
				$('p#form_error', $form).text(error).show()
			else
				@postJSON "/register",
					first_name: $form.find('input[name=first_name]').val()
					last_name: $form.find('input[name=last_name]').val()
					email: $form.find('input[name=email]').val()
				, (response) =>
					gtag('event', 'Join', { event_category: 'Join', event_action: 'JoinRequest', event_label: 'form'}) if typeof gtag is 'function'
					msg = "Thanks for registering your details with TheArticle."
					$('.form_ready').hide()
					$('#form_success').text(msg).show()
					$('#form_close').show()
				, (response) =>
					$('p#form_error', $form).text(response.message).show()

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
			if $clicked.prop('tagName') isnt "BUTTON"
				if $clicked.prop('tagName') is "DIV" and $clicked.data('href')
					link = $clicked.data('href')
				else
					link = $clicked.closest('[data-href]').data('href')
				window.location.href = link

	truncateNearestWord: (str, maxLen, separator = ' ') =>
		if (str.length <= maxLen)
			return str
		else
			return str.substr 0, str.lastIndexOf(separator, maxLen)

	isValidEmailAddress: (email) =>
		return false if email.length is 0
		pattern = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
		return pattern.test email

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


