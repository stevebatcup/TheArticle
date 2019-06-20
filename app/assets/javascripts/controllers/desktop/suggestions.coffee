class TheArticle.Suggestions extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$timeout'
	  '$interval'
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
			loaded: false
		@getSuggestions()

		if @element.data('full-page-suggestions')
			@scope.followCounts =
				followers: 0
				followings: 0
				connections: 0
			@updateMyFollowCounts()
			@interval =>
				@updateMyFollowCounts()
			, 10000


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
			@scope.suggestions.loaded = true
			if (@scope.suggestions.forYous.length is 0) and (@scope.suggestions.populars.length > 0)
				@scope.suggestions.mode = 'populars'

	buildListForSidebox: =>
		if @scope.suggestions.populars.length is 0
			list = @scope.suggestions.forYous
		else if @scope.suggestions.populars.length < 3
			list = @scope.suggestions.populars.concat(@scope.suggestions.forYous)
		else
			list = @scope.suggestions.populars
		@scope.suggestions.listForSidebox = list.slice(0, 3)

	toggleFollowUserFromCard: (member) =>
		@toggleFollowSuggestion(member)

	toggleFollowSuggestion: (member) =>
		if member.imFollowing
			member.imFollowing = false
			@unfollowSuggestion member.id, =>
				@flash "You are no longer following <b>#{member.displayName}</b>"
				@rootScope.$broadcast 'update_follows_from_suggestions', { action: 'unfollow' }
		else
			member.imFollowing = true
			@followSuggestion member.id, =>
				@flash "You are now following <b>#{member.displayName}</b>"
				@rootScope.$broadcast 'update_follows_from_suggestions', { action: 'follow' }

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

	ignoreSuggestion: (member, $event) =>
		$event.preventDefault()
		@ignoreSuggestedMember member.id, =>
			@timeout =>
				@scope.suggestions.forYous = _.filter @scope.suggestions.forYous, (item) =>
					item.id isnt member.id
				@scope.suggestions.populars = _.filter @scope.suggestions.populars, (item) =>
					item.id isnt member.id
				@scope.suggestions.listForSidebox = _.filter @scope.suggestions.listForSidebox, (item) =>
					item.id isnt member.id
			, 300


TheArticle.ControllerModule.controller('SuggestionsController', TheArticle.Suggestions)