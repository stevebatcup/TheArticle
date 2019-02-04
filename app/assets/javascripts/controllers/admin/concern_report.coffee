class TheArticle.ConcernReport extends TheArticle.AdminPageController

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

	markAsSeen: ($event, id, section) =>
		$event.preventDefault()
		@http.get("/admin/mark_concern_report_as_seen?id=#{id}").then (response) =>
			if response.data.status is 'success'
				@redirectToAdminPage "#{section}_concern_reports"
			else
				@alert response.data.message, "Error marking concern report as seen"

TheArticle.ControllerModule.controller('ConcernReportController', TheArticle.ConcernReport)