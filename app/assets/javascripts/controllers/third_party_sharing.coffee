class TheArticle.ThirdPartySharing extends TheArticle.PageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$timeout'
	  '$ngConfirm'
	]

	init: ->
		@setDefaultHttpHeaders()
		@scope.ratingsTouched =
			well_written: false
			valid_points: false
			agree: false
		@scope.thirdPartyArticle =
			url: ''
			urlError: ''
			article:
				error: false
				loaded: false
				data: {}
				share:
					comments: ''
					rating_well_written: 0
					rating_valid_points: 0
					rating_agree: 0
		@bindWatchers()

	bindWatchers: =>
		@scope.$watch 'thirdPartyArticle.article.share.rating_well_written', (newVal, oldVal) =>
			if (newVal isnt oldVal) and (oldVal > 0)
				@scope.ratingsTouched.well_written = true
		@scope.$watch 'thirdPartyArticle.article.share.rating_valid_points', (newVal, oldVal) =>
			if (newVal isnt oldVal) and (oldVal > 0)
				@scope.ratingsTouched.valid_points = true
		@scope.$watch 'thirdPartyArticle.article.share.rating_agree', (newVal, oldVal) =>
			if (newVal isnt oldVal) and (oldVal > 0)
				@scope.ratingsTouched.agree = true


	keyPressedArticleUrl: ($event) =>
		@readArticleUrl() if $event.keyCode is 13

	pastedArticleUrl: ($event) =>
		@timeout =>
			@readArticleUrl()
		, 500

	readArticleUrl: =>
		if @isValidUrl(@scope.thirdPartyArticle.url)
			@scope.thirdPartyArticle.urlError = ''
			@scope.thirdPartyArticle.article.data = {}
			@scope.thirdPartyArticle.article.loaded = false
			data =
				article:
					url: @scope.thirdPartyArticle.url
			@http.post("/third_party_article", data).then (response) =>
				if response.data.status is 'error'
					@scope.thirdPartyArticle.urlError = response.data.message
				else if response.data.status is 'success'
					@scope.thirdPartyArticle.article.data = response.data.article
					@scope.thirdPartyArticle.article.loaded = true

	shareArticle: =>
		@scope.thirdPartyArticle.article.error = false
		data =
			article: @scope.thirdPartyArticle.article.data
			post: @scope.thirdPartyArticle.article.share.comments
			rating_well_written: @scope.thirdPartyArticle.article.share.rating_well_written
			rating_valid_points: @scope.thirdPartyArticle.article.share.rating_valid_points
			rating_agree: @scope.thirdPartyArticle.article.share.rating_agree

		if (@scope.ratingsTouched.well_written is false) and (@scope.thirdPartyArticle.article.share.rating_well_written is 1)
			data['rating_well_written'] = 0
		if (@scope.ratingsTouched.valid_points is false) and (@scope.thirdPartyArticle.article.share.rating_valid_points is 1)
			data['rating_valid_points'] = 0
		if (@scope.ratingsTouched.agree is false) and (@scope.thirdPartyArticle.article.share.rating_agree is 1)
			data['rating_agree'] = 0

		# console.log data
		# console.log @scope.ratingsTouched
		@http.post("/submit_third_party_article", { share: data }).then (response) =>
			if response.data.status is 'success'
				$('.close_share_modal').first().click()
			else
				@scope.thirdPartyArticle.article.error = response.data.message



TheArticle.ControllerModule.controller('ThirdPartySharingController', TheArticle.ThirdPartySharing)