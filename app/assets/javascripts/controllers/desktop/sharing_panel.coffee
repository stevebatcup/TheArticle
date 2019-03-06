class TheArticle.SharingPanel extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$timeout'
	  '$element'
	  '$compile'
	  '$cookies'
	]

	init: ->
		@setDefaultHttpHeaders()
		@scope.formError = false
		@scope.ratingTextLabels = @element.data('rating-text-labels')
		@scope.ratingsTouched =
			well_written: false
			valid_points: false
			agree: false

		@resetData()
		@scope.alreadyRated = parseInt(@element.data('share-well_written')) > 0 or parseInt(@element.data('share-valid_points')) > 0 or parseInt(@element.data('share-agree')) > 0
		@setRatingsDefaultHeading()
		@bindEvents()

	resetData: =>
		@scope.share =
			comments: @element.data('share-comments')
			rating_well_written: @element.data('share-well_written')
			rating_valid_points: @element.data('share-valid_points')
			rating_agree: @element.data('share-agree')

	setRatingsDefaultHeading: =>
		notYetRatedHeading = "Add a rating?"
		alreadyRatedHeading = "You have already rated this article - view rating"
		@scope.ratingsHeading = if @scope.alreadyRated then alreadyRatedHeading else notYetRatedHeading

	bindEvents: =>
		$(document).on 'show.bs.collapse', '#ratings_box', =>
			@scope.$apply =>
				@scope.ratingsHeading = "Rate this article"
		$(document).on 'hide.bs.collapse', '#ratings_box', =>
			@scope.$apply =>
				@setRatingsDefaultHeading()

		@scope.$watch 'share.rating_well_written', (newVal, oldVal) =>
			if (newVal isnt oldVal) and (oldVal > 0)
				@scope.ratingsTouched.well_written = true
		@scope.$watch 'share.rating_valid_points', (newVal, oldVal) =>
			if (newVal isnt oldVal) and (oldVal > 0)
				@scope.ratingsTouched.valid_points = true
		@scope.$watch 'share.rating_agree', (newVal, oldVal) =>
			if (newVal isnt oldVal) and (oldVal > 0)
				@scope.ratingsTouched.agree = true

		$(document).on 'hidden.bs.modal', "#sharingPanelModal", =>
			@resetData()

		@scope.$on 'copy_started_comments', (e, data) =>
			@scope.share.comments = data.comments

	toggleDots: (section, rating) =>
		@scope.share["rating_#{section}"] = rating

	submitShare: =>
		@scope.formError = false
		data =
			article_id: @element.data('article-id')
			share_type: if @rootScope.sharingPanelMode is 'share' then 'share' else 'rating'
			post: @scope.share.comments
			rating_well_written: if @rootScope.sharingPanelMode is 'share' then null else @scope.share.rating_well_written
			rating_valid_points: if @rootScope.sharingPanelMode is 'share' then null else @scope.share.rating_valid_points
			rating_agree: if @rootScope.sharingPanelMode is 'share' then null else @scope.share.rating_agree

		# if (@scope.ratingsTouched.well_written is false) and (@scope.share.rating_well_written is 1)
		# 	data['rating_well_written'] = 0
		# if (@scope.ratingsTouched.valid_points is false) and (@scope.share.rating_valid_points is 1)
		# 	data['rating_valid_points'] = 0
		# if (@scope.ratingsTouched.agree is false) and (@scope.share.rating_agree is 1)
		# 	data['rating_agree'] = 0

		@http.post("/share", { share: data }).then (response) =>
			if response.data.status is 'success'
				$('.close_share_modal').first().click()
				@cookies.put('ok_to_flash', true)
				window.location.reload()
			else
				@scope.formError = response.data.message

	expandCommentsBox: ($event) =>
		$textarea = $($event.target)
		$textarea.addClass('expanded')

	contractCommentsBox: ($event) =>
		$textarea = $($event.target)
		$textarea.removeClass('expanded')

	openRatingsBox: ($event) =>
		$event.preventDefault()
		mode = if @scope.alreadyRated then 'rerate' else 'rate'
		@rootScope.$broadcast 'swap_share_panel', { mode: mode, startedComments: @scope.share.comments }

TheArticle.ControllerModule.controller('SharingPanelController', TheArticle.SharingPanel)