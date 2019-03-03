class TheArticle.TestingFeedback extends TheArticle.PageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$ngConfirm'
	]

	init: ->
		@scope.feedback =
			error: false
			data:
				device: @element.data('device')
				platform: @element.data('platform')
				browser: @element.data('browser')
				url: @element.data('url')
				name: ''
				comments: ''

	submitFeedbackForm: ($event) =>
		$event.preventDefault()
		@scope.feedback.error = false
		if !@scope.feedback.data.name or @scope.feedback.data.name.length is 0
			@scope.feedback.error = "Please enter your name"
		else if !@scope.feedback.data.url or @scope.feedback.data.url.length is 0
			@scope.feedback.error = "Please enter the URL for your feedback"
		else if !@scope.feedback.data.comments or @scope.feedback.data.comments.length is 0
			@scope.feedback.error = "Please give a bit more details in the comments box"
		else
			@postJSON '/submit-feedback', { feedback: @scope.feedback.data }, (response) =>
				$("#testDomainFeedbackFormModal").modal('hide')
				@alert "Thanks for your feedback", "Done"
			, (response) =>
				@alert "Sorry there has been an error submitting your feedback (#{response.message}), please try again", "Error"

TheArticle.ControllerModule.controller('TestingFeedbackController', TheArticle.TestingFeedback)