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

	toggleFollowUserFromCard: (member) =>
		member.imFollowing = true
		@followUser member.id, =>
			@timeout =>
				@scope.suggestions.forYous = _.filter @scope.suggestions.forYous, (item) =>
					item.id isnt member.id
				@scope.suggestions.populars = _.filter @scope.suggestions.populars, (item) =>
					item.id isnt member.id
			, 750
		, true

TheArticle.ControllerModule.controller('SuggestionsController', TheArticle.Suggestions)