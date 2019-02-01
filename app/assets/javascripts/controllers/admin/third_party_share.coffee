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
		console.log '3rd party'

	approve: ($event, id) =>
		$event.preventDefault()
		@http.get("/admin/approve_quarantined_third_party_share?id=#{id}").then (response) =>
			if response.data.status is 'success'
				@redirectToAdminPage 'quarantined_third_party_shares'
			else
				@alert response.data.message, "Error approving"

	reject: ($event, id) =>
		$event.preventDefault()
		@http.get("/admin/reject_quarantined_third_party_share?id=#{id}").then (response) =>
			if response.data.status is 'success'
				@redirectToAdminPage 'quarantined_third_party_shares'
			else
				@alert response.data.message, "Error rejecting"

	delete: ($event, id) =>
		$event.preventDefault()
		@http.get("/admin/delete_quarantined_third_party_share?id=#{id}").then (response) =>
			if response.data.status is 'success'
				@redirectToAdminPage 'quarantined_third_party_shares'
			else
				@alert response.data.message, "Error deleting"

TheArticle.ControllerModule.controller('ThirdPartyShareController', TheArticle.ThirdPartyShare)