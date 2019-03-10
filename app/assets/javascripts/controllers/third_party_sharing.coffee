class TheArticle.ThirdPartySharing extends TheArticle.PageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$timeout'
	  '$ngConfirm'
	  '$compile'
	  '$cookies'
	]

	init: ->
		@setDefaultHttpHeaders()
		@scope.whitelisted = false
		@scope.ratingTextLabels = @element.data('rating-text-labels')
		@scope.invalidUrl = false
		@resetArticleData()
		@bindListeners()

	resetArticleData: =>
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

	toggleDots: (section, rating) =>
		@scope.thirdPartyArticle.article.share["rating_#{section}"] = rating

	bindListeners: =>
		@rootScope.$on 'third_party_url_sharing', ($event, data) =>
			@scope.thirdPartyArticle.url = data.url
			@readArticleUrl()
		@rootScope.$on 'third_party_url_close', ($event, data) =>
			@resetArticleData()

	keyPressedArticleUrl: ($event) =>
		@readArticleUrl() if $event.keyCode is 13

	pastedArticleUrl: ($event) =>
		@timeout =>
			@readArticleUrl()
		, 500

	readArticleUrl: =>
		@scope.invalidUrl = false
		if @isValidUrl(@scope.thirdPartyArticle.url)
			@scope.thirdPartyArticle.urlError = ''
			@scope.thirdPartyArticle.article.data = {}
			@scope.thirdPartyArticle.article.loaded = false
			data =
				article:
					url: @scope.thirdPartyArticle.url
			@http.post("/third_party_article", data).then (response) =>
				@scope.thirdPartyArticle.article.loaded = true
				if response.data.status is 'error'
					@scope.thirdPartyArticle.urlError = response.data.message
					@scope.invalidUrl = response.data.message.indexOf('preview') < 1
				else if response.data.status is 'success'
					@scope.thirdPartyArticle.article.data = response.data.article

	shareNonWhitelistedArticleConfirm: =>
		tpl = $("#confirmNonWhiteListed").html().trim()
		$content = @compile(tpl)(@scope)
		$('body').append $content
		$("#confirmNonWhiteListedModal").modal()

	cancelNonWhiteListArticle: ($event) =>
		$event.preventDefault()
		$('[data-dismiss=modal]').click()

	confirmNonWhiteListArticle: ($event) =>
		$event.preventDefault()
		$("#confirmNonWhiteListedModal").modal('hide')
		@shareArticleConfirm()

	shareArticle: =>
		@scope.thirdPartyArticle.article.error = false
		@http.get("check_third_party_whitelist?url=#{@scope.thirdPartyArticle.url}").then (response) =>
			if response.data.status is 'missing'
				@scope.whitelisted = false
				@shareNonWhitelistedArticleConfirm()
			else if response.data.status is 'found'
				@scope.whitelisted = true
				@shareArticleConfirm()

	shareArticleConfirm: =>
		data =
			url: @scope.thirdPartyArticle.url
			article: @scope.thirdPartyArticle.article.data
			post: @scope.thirdPartyArticle.article.share.comments
			rating_well_written: @scope.thirdPartyArticle.article.share.rating_well_written
			rating_valid_points: @scope.thirdPartyArticle.article.share.rating_valid_points
			rating_agree: @scope.thirdPartyArticle.article.share.rating_agree

		@http.post("/submit_third_party_article", { share: data }).then (response) =>
			if response.data.status is 'success'
				flashMsg = if (@scope.whitelisted) and (!_.isEmpty(@scope.thirdPartyArticle.article.data)) then "Post added to your profile. <a class='text-green' href='/my-profile'>View post</a>." else "Your post has been sent to review."
				@flash flashMsg
				@timeout =>
					$('.close_share_modal').first().click()
				, 250
			else
				@scope.thirdPartyArticle.article.error = response.data.message



TheArticle.ControllerModule.controller('ThirdPartySharingController', TheArticle.ThirdPartySharing)