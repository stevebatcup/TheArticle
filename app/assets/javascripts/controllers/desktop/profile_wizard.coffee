class TheArticle.ProfileWizard extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$element'
	  '$timeout'
	  '$ngConfirm'
	  'MyProfile'
	]

	init: ->
		@setDefaultHttpHeaders()
		@disableBackButton()
		@scope.user =
			id: @element.data('user-id')
			location:
				lat: ''
				lng: ''
				value: ''
				countryCode: ''
				error: null
			names:
				displayName:
					value: @element.data('default-display_name')
					error: null
				username:
					value: @element.data('default-username')
					error: null
			selectedExchanges: []

		@scope.exchangesOk = false
		@bindEvents()

		@scope.suggestionSearch =
			value: ''
			error: null
		@scope.followSuggestions = []
		@getFollowSuggestions()
		@bindCookieAcceptance()

	bindEvents: =>
		@bindListingHovers() unless @isTablet()

		$(document).on 'keyup', 'input#user_location', (e) =>
			$input = $('input#user_location')
			value = $input.val()
			if value.length > 2
				@autocompleteLocations $input

		@scope.$watch 'suggestionSearch.value', (newVal, oldVal) =>
			if newVal isnt oldVal
				@searchForSuggestions newVal

		# @scope.$on 'wizard:stepChanged', (event, args) =>
		# 	console.log(args)

	searchForSuggestions: (query)=>
		if query.length > 0
			@scope.suggestionSearch.error = ""
			@http.get("/suggestion-search?query=#{query}&from_wizard=1").then (response) =>
				@scope.followSuggestions = []
				if _.some(response.data.suggestions.searchResults)
					response.data.suggestions.searchResults.forEach (suggestion) =>
						@scope.followSuggestions.push suggestion
				else
					@scope.suggestionSearch.error = "No results found for your search"
		else
			@getFollowSuggestions()

	getFollowSuggestions: =>
		@http.get('/follow-suggestions?show_accepted=true').then (response) =>
			@scope.followSuggestions = []
			if _.some(response.data.suggestions.forYous)
				response.data.suggestions.forYous.forEach (suggestion) =>
					@scope.followSuggestions.push suggestion
			if _.some(response.data.suggestions.populars)
				response.data.suggestions.populars.forEach (suggestion) =>
					@scope.followSuggestions.push suggestion

	autocompleteLocations: ($input) =>
		options =
			types: ['geocode']
			input: $input.val()
			componentRestrictions: {}
			# {country: 'gb'}
		acService = new google.maps.places.AutocompleteService()
		@scope.autocompleteItems = []
		excludeTypes = ['route', 'transit_station', 'point_of_interest', 'premise']
		acService.getPlacePredictions options, (predictions) =>
			if _.some(predictions)
				predictions.forEach (prediction) =>
					# console.log prediction
					if _.intersection(prediction.types, excludeTypes).length < 1
						@scope.$apply =>
							@scope.autocompleteItems.push(prediction)

	populateLocation: (event, prediction) =>
		# console.log event.target.innerHTML
		address = prediction.description
		geocoder = new google.maps.Geocoder()
		placeText = $(event.currentTarget.innerHTML).find(".main_location_text").text()
		@scope.user.location.value = placeText
		geocoder.geocode { 'address': address }, (results, status) =>
			if status is google.maps.GeocoderStatus.OK
				@scope.$apply =>
					@scope.user.location.lat = results[0].geometry.location.lat()
					@scope.user.location.lng = results[0].geometry.location.lng()
					results[0].address_components.forEach (component) =>
						if _.contains(component.types, 'country')
							@scope.user.location.countryCode = component.short_name
		@scope.autocompleteItems = []

	validateNames: (context) =>
		@scope.user.names.displayName.error = @scope.user.names.username.error = false
		if !@scope.user.names.displayName.value?
			@scope.user.names.displayName.error = "Please choose a Display Name"
		else if !(/^[a-z][a-z\s]*$/i.test(@scope.user.names.displayName.value))
			@scope.user.names.displayName.error = "Your display name can only contain letters and a space"
		else if !@scope.user.names.username.value?
			@scope.user.names.username.error = "Please enter a username"
		else if @scope.user.names.username.value.length < 6
			@scope.user.names.username.error = "Your Username must be at least 6 characters long"
		else if !(/^[0-9a-zA-Z_]+$/i.test(@scope.user.names.username.value))
			@scope.user.names.username.error = "Your Username can only contain letters, numbers and an '_'"
		if @scope.user.names.displayName.error or @scope.user.names.username.error
			return false
		else
			return @validateUsername(null, true)

	validateUsernameFromField: =>
		@scope.user.names.username.error = ""
		@validateUsername (result) =>
			@scope.user.names.username.available = result
		, false

	validateUsername: (callback=null, save=false) =>
		url = "/username-availability?username=@#{@scope.user.names.username.value}"
		url += "&save=1" if save is true
		@http.get(url).then (response) =>
			if response.data is false
				@scope.user.names.username.error = "Username has already been taken"
				callback.call(@, false) if callback?
				return false
			else
				callback.call(@, true) if callback?
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

	toggleFollowSuggestion: (member, $event=null) =>
		$event.preventDefault() if $event?
		if member.imFollowing
			@unfollowUser member.id ,=>
				member.imFollowing = false
		else
			@followUser member.id, =>
				member.imFollowing = true
			, true

	submitWizard: =>
		new @MyProfile(@scope.user).create().then (response) =>
			if response.status is 'error'
				@submitWizardError(response.error)
				false
			else
				@scope.redirectWhenDone = response.redirect
				true
		, (error) =>
			@submitWizardError(error.statusText)
			false

	submitWizardError: (msg) =>
		@alert "Sorry there has been an error: #{msg}"

	finishedWizard: =>
		window.location.href = @scope.redirectWhenDone

TheArticle.ControllerModule.controller('ProfileWizardController', TheArticle.ProfileWizard)