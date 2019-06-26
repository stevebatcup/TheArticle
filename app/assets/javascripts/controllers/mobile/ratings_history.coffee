class TheArticle.RatingsHistory extends TheArticle.mixOf TheArticle.MobilePageController, TheArticle.Feeds

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$timeout'
	  '$interval'
	  '$compile'
	  '$ngConfirm'
	  '$sce'
	  '$cookies'
		'ArticleRating'
		'MyProfile'
		'Comment'
		'Opinion'
	]

	init: ->
		$('footer#main_footer_top, footer#main_footer_bottom').hide()
		@setDefaultHttpHeaders()
		@rootScope.isSignedIn = true
		@articleId = @element.data('article-id')
		@bindEvents()
		vars = @getUrlVars()

		@scope.ratings =
			data: []
			page: 1
			firstLoaded: false
			loading: true
			totalItems: 0
			moreToLoad: true

		@scope.perPage = 16

		@scope.replyingToComment =
			comment: {}
			parentComment: {}
			replyingToReply: false
		@scope.postingComment = false
		@scope.commentPostButton = "Post Comment"
		@scope.commentForSubmission =
			value: ''
		@scope.commentChildLimit = false
		@scope.authActionMessage =
			heading: ''
			msg: ''
		@scope.myProfile = {}

		@timeout =>
			@getMyProfile @getRatings
		, 800

	bindEvents: =>
		super
		@bindScrollEvent()

		$(document).on 'click', ".mentioned_user", (e) =>
			$clicked = $(e.currentTarget)
			userId = $clicked.data('user')
			window.location.href = "/profile-by-id/#{userId}"

	bindScrollEvent: =>
		$win = $(window)
		$win.on 'scroll', =>
			if (@scope.ratings.moreToLoad is true) and (!@scope.ratings.loading)
				scrollTop = $win.scrollTop()
				docHeight = @getDocumentHeight()
				if (scrollTop + $win.height()) >= (docHeight - 700)
					@scope.ratings.moreToLoad = false
					@loadMore()

	loadMore: =>
		@getRatings()

	getRatings: =>
		@ArticleRating.get({ page: @scope.ratings.page, per_page: @scope.perPage, id: @articleId }).then (response) =>
			@scope.ratings.loading = false
			@scope.ratings.firstLoaded = true
			angular.forEach response.ratings, (rating, index) =>
				@scope.ratings.data.push rating
			if @scope.ratings.page is 1
				@scope.article = response.article
				@scope.ratings.totalItems = response.total
			@scope.ratings.moreToLoad = (@scope.ratings.totalItems > @scope.ratings.length)

	trustAsHtml: (html) =>
		@sce.trustAsHtml(html)

	getMyProfile: (callback=null) =>
		@MyProfile.get().then (profile) =>
			@scope.myProfile = profile
			callback.call(@) if callback?

TheArticle.ControllerModule.controller('RatingsHistoryController', TheArticle.RatingsHistory)