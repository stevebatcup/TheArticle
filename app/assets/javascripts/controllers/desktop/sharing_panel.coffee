class TheArticle.SharingPanel extends TheArticle.DesktopPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$timeout'
	  '$interval'
	  '$element'
	  '$compile'
	  '$cookies'
	]

	init: ->
		@setDefaultHttpHeaders()
		@scope.formError = false
		@scope.ratingTextLabels = @element.data('rating-text-labels')
		@scope.sharing = false

		@resetData()
		@scope.alreadyRated = parseInt(@element.data('share-well_written')) > 0 or parseInt(@element.data('share-valid_points')) > 0 or parseInt(@element.data('share-agree')) > 0
		@setRatingsDefaultHeading()
		@bindEvents()

		@scope.tinymceOptions =
			selector: 'textarea#comments'
			height: 56
			placeholder: "Add a comment..."
			statusbar: false
			menubar: false
			toolbar: false
			init_instance_callback: (editor) =>
				editor.on 'focus', (e) =>
					editor.theme.resizeTo('100%', 144)
			mentions:
				items: 6
				delay: 0
				queryBy: 'username'
				render: (item) =>
					return "<li><a href='javascript:;'>
							<img src='#{item.image}' alt='' class='rounded-circle' />
							<span class='text'>#{item.username} (#{item.displayname})</span>
						</a></li>"
				insert: (item) =>
					'<span class="mentioned_user" style="font-weight:bold;" data-user="' + item.id + '">' + item.username + '</span>';
				highlighter: (text) ->
					text.replace new RegExp('(' + this.query + ')', 'ig'), ($1, match) ->
						'<i>' + match + '</i>'
				source: (query, process, delimiter) =>
					if delimiter is '@'
						if query.length > 1
							@http.get("/profile/search-by-username/#{query}").then (response) =>
								process(response.data.results) if response.data.results?
						else
							[]
			plugins : "link, paste, placeholder"
			external_plugins:
				'mention' : 'http://stevendevooght.github.io/tinyMCE-mention/javascripts/tinymce/plugins/mention/plugin.js'
			content_css: [
				@element.data('tinymce-content-css-url'),
				'//fonts.googleapis.com/css?family=Montserrat'
			]

	resetData: =>
		@scope.share =
			comments: @element.data('share-comments')
			rating_well_written: @element.data('share-well_written')
			rating_valid_points: @element.data('share-valid_points')
			rating_agree: @element.data('share-agree')
			share_on_twitter: false

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

		$(document).on 'hidden.bs.modal', "#sharingPanelModal", =>
			@resetData()

		@scope.$on 'copy_started_comments', (e, data) =>
			@scope.share.comments = data.comments

	toggleDots: (section, rating) =>
		@scope.share["rating_#{section}"] = rating

	submitShare: =>
		@scope.sharing = true
		@scope.formError = false
		data =
			article_id: @element.data('article-id')
			share_type: if @rootScope.sharingPanelMode is 'share' then 'share' else 'rating'
			post: @scope.share.comments
			rating_well_written: if @rootScope.sharingPanelMode is 'share' then null else @scope.share.rating_well_written
			rating_valid_points: if @rootScope.sharingPanelMode is 'share' then null else @scope.share.rating_valid_points
			rating_agree: if @rootScope.sharingPanelMode is 'share' then null else @scope.share.rating_agree

		@http.post("/share", { share: data }).then (response) =>
			if response.data.status is 'success'
				$('.close_share_modal').first().click()
				@cookies.put('ok_to_flash', true)
				@scope.sharing = false
				if @scope.share.share_on_twitter
					@openTweetWindow(false)
				else
					window.location.reload()
			else
				@scope.formError = response.data.message

	openFacebookWindow: =>
		articleUrl = window.location.toString()
		url = "https://www.facebook.com/sharer/sharer.php?u=#{articleUrl}"
		@openSocialShareWindow url, =>
			window.location.reload()

	openTweetWindow: (alsoOpenFacebookWindow=false) =>
		articleUrl = window.location.toString()
		wellWritten = "#{@scope.share.rating_well_written}/5"
		interesting = "#{@scope.share.rating_valid_points}/5"
		agree = "#{@scope.share.rating_agree}/5"
		ratingTweet = "I gave this the following rating on TheArticle: Well written #{wellWritten}, Interesting #{interesting}, Agree #{agree}. #{@scope.share.comments}"
		url = "https://twitter.com/intent/tweet?url=#{articleUrl}&text=#{ratingTweet}"
		if alsoOpenFacebookWindow
			callback = @openFacebookWindow
		else
			callback = =>
				window.location.reload()
		@openSocialShareWindow url, callback

	openSocialShareWindow: (url, callback=null) =>
		width = 600
		height = 471
		left = (screen.width/2)-(width/2)
		top = (screen.height/2)-(height/2)
		@shareWindow = window.open(url, 'shareWindow', 'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no, width='+width+', height='+height+', top='+top+', left='+left)
		timer = @interval =>
			if ('shareWindow' of @) and (@shareWindow.closed)
				@interval.cancel(timer)
				callback.call(@) if callback?
		, 1000

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