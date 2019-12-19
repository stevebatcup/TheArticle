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
		@scope.userForBox.blacklisted = true
		@http.get("/admin/add_user_to_blacklist?user_id=#{@scope.userForBox.id}").then (response) =>
			if response.data.status isnt 'success'
				@scope.userForBox.blacklisted = false

	addToWatchList: ($event) =>
		@scope.userForBox.watchlisted = true
		$event.preventDefault()
		@http.get("/admin/add_user_to_watchlist?user_id=#{@scope.userForBox.id}").then (response) =>
			if response.data.status isnt 'success'
				@scope.userForBox.watchlisted = false

	deactivate: ($event) =>
		$event.preventDefault()
		q = "Are you sure you wish to deactivate #{@scope.userForBox.name}'s account?"
		@confirm q, @deactivateConfirm, null, "Sure?", ["No", "Yes, deactivate"]

	deactivateConfirm: =>
		originalStatus = @scope.userForBox.status
		@scope.userForBox.status = 'deactivated'
		@scope.userForBox.deactivated = true
		@http.get("/admin/deactivate_user?user_id=#{@scope.userForBox.id}").then (response) =>
			if response.data.status isnt 'success'
				@scope.userForBox.status = originalStatus
				@scope.userForBox.deactivated = false

	reactivate: ($event) =>
		originalStatus = @scope.userForBox.status
		@scope.userForBox.status = 'active'
		@scope.userForBox.deactivated = false
		$event.preventDefault()
		@http.get("/admin/reactivate_user?user_id=#{@scope.userForBox.id}").then (response) =>
			if response.data.status isnt 'success'
				@scope.userForBox.status = originalStatus
				@scope.userForBox.deactivated = true

	delete: ($event) =>
		$event.preventDefault()
		q = "Are you sure you wish to delete #{@scope.userForBox.name}'s account?"
		@confirm q, @deleteConfirm, null, "Sure?", ["No", "Yes, delete"]

	deleteConfirm: =>
		originalStatus = @scope.userForBox.status
		@scope.userForBox.status = 'deleted'
		@scope.userForBox.deleted = true
		@http.delete("/admin/delete_user?user_id=#{@scope.userForBox.id}").then (response) =>
			if response.data.status isnt 'success'
				@scope.userForBox.status = originalStatus
				@scope.userForBox.deleted = false

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

	removeLinkedAccount: (id, $event) =>
		$event.preventDefault()
		@http.delete("/admin/delete_linked_account?user_id=#{@scope.userForBox.id}&linked_account_id=#{id}").then (response) =>
			if response.data.status is 'success'
				@scope.userForBox.linkedAccounts = _.reject @scope.userForBox.linkedAccounts, (item) =>
					item.id is id

	addLinkedAccount: =>
		@scope.userForBox.addingLinkedAccount.css = ''
		@scope.userForBox.addingLinkedAccount.message = ''
		if @scope.userForBox.addingLinkedAccount.id.length is 0 || isNaN(@scope.userForBox.addingLinkedAccount.id)
			@scope.userForBox.addingLinkedAccount.css = 'text-danger'
			@scope.userForBox.addingLinkedAccount.message = 'Enter a valid account ID'
		else
			data =
				user_id: @scope.userForBox.id
				linked_account: @scope.userForBox.addingLinkedAccount.id
			@http.post("/admin/add_linked_account", data).then (response) =>
				if response.data.status is 'success'
					@scope.userForBox.addingLinkedAccount.id = ''
					@scope.userForBox.addingLinkedAccount.css = 'text-green'
					@scope.userForBox.addingLinkedAccount.message = 'Account successfully linked'
					@scope.userForBox.linkedAccounts.push { id: response.data.id, displayName: response.data.displayName }
					@timeout =>
						@scope.userForBox.addingLinkedAccountStatus = ''
					, 3000
				else
					@scope.userForBox.addingLinkedAccount.css = 'text-danger'
					@scope.userForBox.addingLinkedAccount.message = response.data.message

	updateBio: =>
		data =
			user_id: @scope.userForBox.id
			bio: @scope.userForBox.bio
			send_alert: @scope.userForBox.alertBioUpdated
		@http.post("/admin/update-user-bio", data).then (response) =>
			if response.data.status is 'error'
				alert response.data.message, "Whoops!"
			else if response.data.status is 'success'
				@scope.userForBox.bioUpdated = true

TheArticle.ControllerModule.controller('UserController', TheArticle.User)