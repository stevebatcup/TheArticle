class TheArticle.User extends TheArticle.AdminPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$compile'
	  '$timeout'
	  '$compile'
	  '$ngConfirm'
	]

	init: ->
		@setDefaultHttpHeaders()
		@setCsrfTokenHeaders()
		@watch()

	watch: =>
		@scope.$watch 'userForBox.fullDetailsLoaded', (oldVal, newVal) =>
			if newVal isnt oldVal
				@scope.availableAuthors = []
				@getAvailableAuthors()

	addToBlackList: ($event) =>
		$event.preventDefault()
		q = "Are you sure you wish to delete #{@scope.userForBox.name}'s account and add them to the blacklist?"
		@confirm q, @addToBlackListConfirm, null, "Sure?", ["No", "Yes, delete and blacklist"]

	addToBlackListConfirm: =>
		@http.get("/admin/add_user_to_blacklist?user_id=#{@scope.userForBox.id}").then (response) =>
			@scope.userForBox.blacklisted = true

	addToWatchList: ($event) =>
		$event.preventDefault()
		@http.get("/admin/add_user_to_watchlist?user_id=#{@scope.userForBox.id}").then (response) =>
			@scope.userForBox.watchlisted = true

	deactivate: ($event) =>
		$event.preventDefault()
		q = "Are you sure you wish to deactivate #{@scope.userForBox.name}'s account?"
		@confirm q, @deactivateConfirm, null, "Sure?", ["No", "Yes, deactivate"]

	deactivateConfirm: =>
		@http.get("/admin/deactivate_user?user_id=#{@scope.userForBox.id}").then (response) =>
			@scope.userForBox.status = 'deactivated'
			@scope.userForBox.deactivated = true

	reactivate: ($event) =>
		$event.preventDefault()
		@http.get("/admin/reactivate_user?user_id=#{@scope.userForBox.id}").then (response) =>
			@scope.userForBox.status = 'active'
			@scope.userForBox.deactivated = false

	delete: ($event) =>
		$event.preventDefault()
		q = "Are you sure you wish to delete #{@scope.userForBox.name}'s account?"
		@confirm q, @deleteConfirm, null, "Sure?", ["No", "Yes, delete"]

	deleteConfirm: =>
		@http.delete("/admin/delete_user?user_id=#{@scope.userForBox.id}").then (response) =>
			@scope.userForBox.status = 'deleted'
			@scope.userForBox.deleted = true

	getAvailableAuthors: =>
		@http.get("/admin/available_authors_for_user/#{@scope.userForBox.id}").then (response) =>
			@scope.availableAuthors = response.data.authors
			if 'authorId' of @scope.userForBox
				angular.forEach @scope.availableAuthors, (author) =>
					if Number(author.id) is Number(@scope.userForBox.authorId)
						@scope.userForBox.author = author

	updateAuthor: =>
		data =
			user_id: @scope.userForBox.id
			author_id: if @scope.userForBox.author then @scope.userForBox.author.id else null
		@http.post("/admin/set_author_for_user", data)

	updateGenuineVerified: =>
		data =
			user_id: @scope.userForBox.id
			genuine_verified: if @scope.userForBox.genuineVerified then 1 else 0
		@http.post("/admin/set_genuine_verified_for_user", data)

	removeAdditionalEmail: (id, $event) =>
		$event.preventDefault()
		@http.delete("/admin/delete_additional_email?user_id=#{@scope.userForBox.id}&email_id=#{id}").then (response) =>
			if response.data.status is 'success'
				@scope.userForBox.additionalEmails = _.reject @scope.userForBox.additionalEmails, (item) =>
					item.id is id

	addAdditionalEmail: =>
		@scope.userForBox.addingAdditionalEmail.css = ''
		@scope.userForBox.addingAdditionalEmail.message = ''
		if !@scope.userForBox.addingAdditionalEmail.text or @scope.userForBox.addingAdditionalEmail.text.length is 0
			@scope.userForBox.addingAdditionalEmail.css = 'text-danger'
			@scope.userForBox.addingAdditionalEmail.message = 'Enter a valid email address'
		else
			data =
				user_id: @scope.userForBox.id
				email: @scope.userForBox.addingAdditionalEmail.text
			@http.post("/admin/add_additional_email", data).then (response) =>
				@scope.userForBox.addingAdditionalEmail.text = ''
				@scope.userForBox.addingAdditionalEmail.css = 'text-green'
				@scope.userForBox.addingAdditionalEmail.message = 'Email address successfully added'
				@scope.userForBox.additionalEmails.push { id: response.data.id, text: response.data.text }
				@timeout =>
					@scope.userForBox.addingAdditionalEmailStatus = ''
				, 3000

TheArticle.ControllerModule.controller('UserController', TheArticle.User)