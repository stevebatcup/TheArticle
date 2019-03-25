class TheArticle.Suggestions extends TheArticle.DesktopPageController

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

	getSuggestions: =>
		console.log 'getSuggestions'
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
		if member.imFollowing
			member.imFollowing = false
			@unfollowSuggestion member.id, =>
				@flash "You are no longer following <b>#{member.displayName}</b>"
				@rootScope.$broadcast 'update_follows_from_suggestions'
		else
			member.imFollowing = true
			@followSuggestion member.id, =>
				@flash "You are now following <b>#{member.displayName}</b>"
				@rootScope.$broadcast 'update_follows_from_suggestions'

	followSuggestion: (userId, callback) =>
		@http.post("/user_followings", {id: userId, from_suggestion: true}).then (response) =>
			if response.data.status is 'success'
				callback.call(@)
			else if response.data.status is 'error'
				@alert response.data.message, "Error following user"

	unfollowSuggestion: (userId, callback) =>
		@http.delete("/user_followings/#{userId}").then (response) =>
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