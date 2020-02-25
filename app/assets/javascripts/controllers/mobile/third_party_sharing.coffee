class TheArticle.ThirdPartySharing extends TheArticle.MobilePageController

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
		@scope.ratingTextClasses = @element.data('rating-text-classes')
		@scope.invalidUrl = false
		@scope.sharing = false
		@resetArticleData()
		@bindListeners()
		@scope.urlTinymceOptions = @setUrlTinyMceOptions()
		@scope.tinymceOptions = @setTinyMceOptions()

	resetArticleData: =>
		@scope.thirdPartyArticle =
			url: ''
			urlError: ''
			article:
				error: false
				loaded: false
				data: {}
				previouslyRated: false
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
		@scope.thirdPartyArticle.url = @scope.thirdPartyArticle.url.replace(/(<([^>]+)>)/ig,"").trim()
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
					if 'previous_rated_article' of response.data
						@scope.thirdPartyArticle.article.previouslyRated = true
						@scope.thirdPartyArticle.article.share = response.data.previous_rated_article
					else
						@scope.thirdPartyArticle.article.previouslyRated = false
						@scope.thirdPartyArticle.article.share = { comments: '', rating_well_written: 0, rating_valid_points: 0, rating_agree: 0 }
		else
			@scope.thirdPartyArticle.article.loaded = true
			@scope.thirdPartyArticle.urlError = "We're sorry but there is a problem sharing this URL. This might be, for example, because it is not an article URL or because the article's publication does not allow shares. Please press cancel to continue using the site."
			@scope.invalidUrl = true

	shareNonWhitelistedArticleConfirm: =>
		tpl = $("#confirmNonWhiteListed").html().trim()
		$content = @compile(tpl)(@scope)
		$('body').append $content
		$("#confirmNonWhiteListedModal").modal()

	cancelNonWhiteListArticle: ($event) =>
		$event.preventDefault()
		$('[data-dismiss=modal]').click()
		@scope.sharing = false

	confirmNonWhiteListArticle: ($event) =>
		$event.preventDefault()
		$("#confirmNonWhiteListedModal").modal('hide')
		@shareArticleConfirm()

	shareArticle: =>
		@scope.sharing = true
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
				msg = if @scope.thirdPartyArticle.article.previouslyRated then "Post updated" else "Post added to your profile"
				flashMsg = if (@scope.whitelisted) and (!_.isEmpty(@scope.thirdPartyArticle.article.data)) then "#{msg}. <a class='text-green' href='/my-profile'>View post</a>." else "Your post has been sent to review."
				@flash flashMsg
				@timeout =>
					$('.close_share_modal').first().click()
					@scope.sharing = false
				, 250
			else
				@scope.thirdPartyArticle.article.error = response.data.message
				@scope.sharing = false

	setUrlTinyMceOptions: =>
		baseURL: "/tinymce-host"
		selector: 'textarea#third_party_article_url'
		min_height: 77
		height: 77
		statusbar: false
		menubar: false
		toolbar: false
		setup: (editor) =>
			@scope.currentTinyMceEditor = editor
		init_instance_callback: (ed) =>
			ed.on 'focus', (e) =>
				ed.theme.resizeTo('100%', 77)
			ed.on 'keydown', (e) =>
				@keyPressedArticleUrl(e)
			ed.on 'paste', (e) =>
				@pastedArticleUrl(e)
		plugins : "link, paste"
		content_css: [
			@element.data('tinymce-content-css-url'),
			'//fonts.googleapis.com/css?family=Montserrat'
		]

TheArticle.ControllerModule.controller('ThirdPartySharingController', TheArticle.ThirdPartySharing)