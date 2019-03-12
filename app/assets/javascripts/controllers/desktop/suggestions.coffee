class TheArticle.Suggestions extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$timeout'
	  '$compile'
	]

	init: ->
		@setDefaultHttpHeaders()
		@bindEvents()
		@scope.suggestions =
			mode: 'forYous'
			total: 0
			listForSidebox: []
			forYous: []
			populars: []
		@getSuggestions()

	selectSuggestionTab: ($event, tab) =>
		$event.preventDefault()
		@scope.suggestions.mode = tab

	getSuggestions: (isMe) =>
		@http.get('/follow-suggestions').then (response) =>
			angular.forEach response.data.suggestions.forYous, (suggestion) =>
				@scope.suggestions.forYous.push suggestion
			angular.forEach response.data.suggestions.populars, (suggestion) =>
				@scope.suggestions.populars.push suggestion
			@scope.suggestions.total = @scope.suggestions.populars.length + @scope.suggestions.forYous.length
			@buildListForSidebox()
			if (@scope.suggestions.forYous.length is 0) and (@scope.suggestions.populars.length > 0)
				@scope.suggestions.mode = 'populars'

	buildListForSidebox: =>
		@scope.suggestions.listForSidebox = _.shuffle(@scope.suggestions.forYous.concat(@scope.suggestions.populars)).slice(0, 3)

	toggleFollowSuggestion: (member) =>
		@followSuggestion member.id, =>
			member.imFollowing = true
			@flash "You are now following <b>#{member.displayName}</b>"

	followSuggestion: (userId, callback) =>
		@http.post("/user_followings", {id: userId, from_suggestion: true}).then (response) =>
			callback.call(@)

	openSuggestionsModal: ($event) =>
		$event.preventDefault()
		@timeout =>
			tpl = $("#allProfileSuggestions").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#allProfileSuggestionsModal").modal()
		, 350

TheArticle.ControllerModule.controller('SuggestionsController', TheArticle.Suggestions)