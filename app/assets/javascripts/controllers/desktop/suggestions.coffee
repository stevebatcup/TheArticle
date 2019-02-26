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
		@scope.suggestions.listForSidebox = @scope.suggestions.forYous.slice(0, 2)
		remainder = 3 - @scope.suggestions.listForSidebox.length
		populars = @scope.suggestions.populars.slice(0, remainder)
		if populars.length > 0
			angular.forEach populars, (suggestion) =>
				@scope.suggestions.listForSidebox.push suggestion
		@scope.suggestions.listForSidebox = _.shuffle(@scope.suggestions.listForSidebox)

	toggleFollowSuggestion: (member) =>
		@followSuggestion member.id, =>
			member.imFollowing = true
			@timeout =>
				mode = @scope.suggestions.mode
				@scope.suggestions[mode] = _.filter @scope.suggestions[mode], (item) =>
					item.id isnt member.id
			, 750

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