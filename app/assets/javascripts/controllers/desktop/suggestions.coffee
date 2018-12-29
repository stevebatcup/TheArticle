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
		@scope.suggestions =
			forYous: []
			populars: []
		@getSuggestions()

	getSuggestions: (isMe) =>
		@http.get('/follow-suggestions').then (response) =>
			@scope.suggestions = response.data.suggestions
			inFollowers: (member) =>
				ids = _.map @scope.follows.followers, (item) =>
					item.id
				ids.indexOf(member.id) isnt -1

	toggleFollowSuggestion: (member) =>
		console.log 'toggleFollowSuggestion'
		@followSuggestion member.id, =>
			member.imFollowing = true
			@timeout =>
				@scope.suggestions.forYous = _.filter @scope.suggestions.forYous, (item) =>
					item.id isnt member.id
				@scope.suggestions.populars = _.filter @scope.suggestions.populars, (item) =>
					item.id isnt member.id
			, 750

	followSuggestion: (userId, callback) =>
		@http.post("/user_followings", {id: userId, from_suggestion: true}).then (response) =>
			callback.call(@)

TheArticle.ControllerModule.controller('SuggestionsController', TheArticle.Suggestions)