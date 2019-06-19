class TheArticle.Suggestions extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$timeout'
	  '$compile'
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
		@followUser member.id, =>
			@timeout =>
				@scope.suggestions = _.filter @scope.suggestions, (item) =>
					item.id isnt member.id
				@scope.forYous = _.filter @scope.forYous, (item) =>
					item.id isnt member.id
				@scope.populars = _.filter @scope.populars, (item) =>
					item.id isnt member.id
			, 750
		, true

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