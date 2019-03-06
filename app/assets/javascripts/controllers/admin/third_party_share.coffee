class TheArticle.ThirdPartyShare extends TheArticle.AdminPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$rootElement'
	  '$compile'
	  '$timeout'
	  '$compile'
	  '$ngConfirm'
	]

	init: ->
		@setDefaultHttpHeaders()

	approve: ($event, id) =>
		$event.preventDefault()
		@confirm "Are you sure you wish to approve this 3rd party post?", =>
			@approveConfirm(id, false)
		, null, "Are you sure?", ["No, cancel", "Yes, approve"]

	approveAndWhitelist: ($event, id) =>
		$event.preventDefault()
		@confirm "Are you sure you wish to approve this 3rd party post and add the domain to the whitelist?", =>
			@approveConfirm(id, true)
		, null, "Are you sure?", ["No, cancel", "Yes, approve"]

	approveConfirm: (id, whitelistDomain=false) =>
		url = "/admin/approve_quarantined_third_party_share?id=#{id}"
		url += "&whitelist_domain=1" if whitelistDomain
		@http.get(url).then (response) =>
			if response.data.status is 'success'
				@redirectToAdminPage 'quarantined_third_party_shares'
			else
				@alert response.data.message, "Error approving"

	reject: ($event, id) =>
		$event.preventDefault()
		@confirm "Are you sure you wish to reject this 3rd party post?", =>
			@http.get("/admin/reject_quarantined_third_party_share?id=#{id}").then (response) =>
				if response.data.status is 'success'
					@redirectToAdminPage 'quarantined_third_party_shares'
				else
					@alert response.data.message, "Error rejecting"
		, null, "Are you sure?", ["No, cancel", "Yes, reject"]

	delete: ($event, id) =>
		$event.preventDefault()
		@confirm "Are you sure you wish to delete this 3rd party post and the user?", =>
			@http.get("/admin/delete_quarantined_third_party_share?id=#{id}").then (response) =>
				if response.data.status is 'success'
					@redirectToAdminPage 'quarantined_third_party_shares'
				else
					@alert response.data.message, "Error deleting"
		, null, "Are you sure?", ["No, cancel", "Yes, reject"]


TheArticle.ControllerModule.controller('ThirdPartyShareController', TheArticle.ThirdPartyShare)