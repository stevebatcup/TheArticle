class TheArticle.SharingPanel extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$timeout'
	  '$element'
	  '$compile'
	]

	init: ->
		@setDefaultHttpHeaders()
		@scope.formError = false
		@scope.ratingsHeading = "Add a rating?"
		@scope.ratingTextLabels = @element.data('rating-text-labels')
		@scope.ratingsTouched =
			well_written: false
			valid_points: false
			agree: false

		@scope.share =
			comments: @element.data('share-comments')
			rating_well_written: @element.data('share-well_written')
			rating_valid_points: @element.data('share-valid_points')
			rating_agree: @element.data('share-agree')
		@bindEvents()

	bindEvents: =>
		$(document).on 'show.bs.collapse', '#ratings_box', =>
			@scope.$apply =>
				@scope.ratingsHeading = "Rate this article"
		$(document).on 'hide.bs.collapse', '#ratings_box', =>
			@scope.$apply =>
				@scope.ratingsHeading = "Add a rating?"

		@scope.$watch 'share.rating_well_written', (newVal, oldVal) =>
			if newVal isnt oldVal
				@scope.ratingsTouched.well_written = true
		@scope.$watch 'share.rating_valid_points', (newVal, oldVal) =>
			if newVal isnt oldVal
				@scope.ratingsTouched.valid_points = true
		@scope.$watch 'share.rating_agree', (newVal, oldVal) =>
			if newVal isnt oldVal
				@scope.ratingsTouched.agree = true

	toggleDots: (section, rating) =>
		@scope.share["rating_#{section}"] = rating

	submitShare: =>
		@scope.formError = false
		data =
			article_id: @element.data('article-id')
			post: @scope.share.comments
			rating_well_written: @scope.share.rating_well_written
			rating_valid_points: @scope.share.rating_valid_points
			rating_agree: @scope.share.rating_agree

		# if (@scope.ratingsTouched.well_written is false) and (@scope.share.rating_well_written is 1)
		# 	data['rating_well_written'] = 0
		# if (@scope.ratingsTouched.valid_points is false) and (@scope.share.rating_valid_points is 1)
		# 	data['rating_valid_points'] = 0
		# if (@scope.ratingsTouched.agree is false) and (@scope.share.rating_agree is 1)
		# 	data['rating_agree'] = 0

		@http.post("/share", { share: data }).then (response) =>
			if response.data.status is 'success'
				$('.close_share_modal').first().click()
				window.location.reload()
			else
				@scope.formError = response.data.message

	expandCommentsBox: ($event) =>
		$textarea = $($event.target)
		$textarea.addClass('expanded')

	contractCommentsBox: ($event) =>
		$textarea = $($event.target)
		$textarea.removeClass('expanded')

TheArticle.ControllerModule.controller('SharingPanelController', TheArticle.SharingPanel)