class TheArticle.Suggestions extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$timeout'
	]

	init: ->
		@setDefaultHttpHeaders()
		@bindEvents()
		@scope.suggestions = []
		@getSuggestions()

	getSuggestions: (isMe) =>
		@http.get('/follow-suggestions').then (response) =>
			angular.forEach response.data.suggestions.forYous, (suggestion) =>
				@scope.suggestions.push suggestion
			angular.forEach response.data.suggestions.populars, (suggestion) =>
				@scope.suggestions.push suggestion

	toggleFollowSuggestion: (member) =>
		@followSuggestion member.id, =>
			member.imFollowing = true
			@timeout =>
				@scope.suggestions = _.filter @scope.suggestions, (item) =>
					item.id isnt member.id
			, 750

	followSuggestion: (userId, callback) =>
		@http.post("/user_followings", {id: userId, from_suggestion: true}).then (response) =>
			callback.call(@)

TheArticle.ControllerModule.controller('SuggestionsController', TheArticle.Suggestions)