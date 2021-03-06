class TheArticle.Suggestions extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$timeout'
	  '$compile'
	  '$sce'
	  '$ngConfirm'
	]

	init: ->
		@scope.loaded = false
		@setDefaultHttpHeaders()
		@bindEvents()
		@scope.suggestions = []
		@scope.forYous = []
		@scope.populars = []
		@getSuggestions()

	getSuggestions: =>
		@http.get('/follow-suggestions').then (response) =>
			angular.forEach response.data.suggestions.forYous, (suggestion) =>
				@scope.suggestions.push suggestion
				@scope.forYous.push suggestion
			angular.forEach response.data.suggestions.populars, (suggestion) =>
				@scope.suggestions.push suggestion
				@scope.populars.push suggestion
			@scope.loaded = true

	toggleFollowUserFromCard: (member) =>
		member.imFollowing = true
		# isMobileApp = @mobileAppDetected()
		@followUser member.id, (response) =>
			@flash response.data.message
			@timeout =>
				@scope.suggestions = _.filter @scope.suggestions, (item) =>
					item.id isnt member.id
				@scope.forYous = _.filter @scope.forYous, (item) =>
					item.id isnt member.id
				@scope.populars = _.filter @scope.populars, (item) =>
					item.id isnt member.id
			, 750
		, true, false, =>
			@timeout =>
				member.imFollowing = false
			, 550

	ignoreSuggestion: (member, $event) =>
		$event.preventDefault()
		@ignoreSuggestedMember member.id, =>
			@timeout =>
				@scope.suggestions = _.filter @scope.suggestions, (item) =>
					item.id isnt member.id
				@scope.forYous = _.filter @scope.forYous, (item) =>
					item.id isnt member.id
				@scope.populars = _.filter @scope.populars, (item) =>
					item.id isnt member.id
			, 300

TheArticle.ControllerModule.controller('SuggestionsController', TheArticle.Suggestions)