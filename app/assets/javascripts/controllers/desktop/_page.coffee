class TheArticle.DesktopPageController extends TheArticle.PageController
	constructor: ->
		super
		@reLinePosts() unless @isTablet()

	bindEvents: =>
		@bindCookieAcceptance()
		@timeout =>
		 @bindCarousels()
		, 700
		@bindContactForm()
		@bindListingHovers() unless @isTablet()
		@bindBlockClicks()
		@bindSearchFilters()

		$('#hidden_editors_picks').on 'shown.bs.collapse', (e) =>
			@reLinePosts() unless @isTablet()

		@timeout =>
			if $('#sidebar').length
				sideBarHeight = $('#sidebar').outerHeight()
				contentHeight = $('#content_box').outerHeight() + $('#img_box').outerHeight()
				if sideBarHeight > 1860
					articleCount = Math.floor((sideBarHeight - 1860) / 376)
					$('h2', '#featured_articles_sidebar').show() if articleCount > 0
					for i in [0...articleCount]
						$("[data-index=#{i+1}]", '#featured_articles_sidebar').show()
				else if sideBarHeight - contentHeight >= 400
					$('#featured_articles_content_bar').show()
		, 2500

		$('#open_feedback_form').on 'click', (e) =>
			@openFeedbackForm(e)

		if @isTablet()
			$(window).on "orientationchange", (e) =>
				@resetCarousels()

	reLinePosts: =>
		$('.article-listing.post').each (index, post) =>
			if $(post).is(':visible')
				id = $(post).data('id')
				if id?
					if title = document.getElementById("article-post-title-#{id}")
						offsetHeight = title.offsetHeight
						lineHeight = parseInt $(title).css('lineHeight'), 10
						lines = offsetHeight / lineHeight
						if lines >= 4 and !$(post).hasClass('relined')
							$description = $(post).find('.entry-content')
							$description.text @truncateNearestWord($description.text(), 50) + " [...]"
							$(post).addClass('relined')

	isTablet: =>
		$('body').hasClass('tablet')

	bindListingHovers: =>
		$(document).on 'mouseover', '.hoveraction', (e) =>
			$(e.currentTarget).addClass('hovered')
		$(document).on 'mouseout', '.hoveraction', (e) =>
			$(e.currentTarget).removeClass('hovered')

	resetCarousels: =>
		$('.slick-carousel').slick('unslick')
		@timeout =>
			@setupCarousels()
		, 200

	bindCarousels: =>
		$(document).on 'init', '.slick-carousel', (e) =>
			window.setTimeout =>
				$(e.currentTarget).find('.inner').addClass('shown')
				$('.cloak').fadeIn('slow').removeClass('cloak').addClass('was_cloaked')
			, 300

		$(document).on 'destroy', '.slick-carousel', (e) =>
			$(e.currentTarget).find('.inner').removeClass('shown')
			$('.was_cloaked').fadeOut('slow').removeClass('was_cloaked').addClass('cloak')

		@setupCarousels()

	setupCarousels: =>
		windowWidith = $(window).width()
		$('.slick-carousel.articles').slick
			infinite: true
			slidesToShow: if windowWidith <= 768 then 2 else 3
			slidesToScroll: 1
			adaptiveHeight: true
			speed: 300
			dots: true
			centerMode: true,
			centerPadding: '60px'

		$('.slick-carousel.exchanges').slick
			infinite: true
			slidesToShow: if windowWidith <= 768 then 2 else 3
			slidesToScroll: 1
			adaptiveHeight: true
			speed: 300
			dots: false
			centerMode: true

		if windowWidith <= 768
			journoSlidesToShow = 3
		else if windowWidith > 1024
			journoSlidesToShow =  5
		else
			journoSlidesToShow =  4
		$('.slick-carousel.journalists').slick
			infinite: true
			slidesToShow: journoSlidesToShow
			slidesToScroll: 1
			adaptiveHeight: true
			speed: 300
			dots: true
			arrows: true
			centerMode: true

	bindFixedNavScrolling: =>
		unless $('[data-no-fixed-header]').length > 0
			$win = $(window)
			$header = $('header#main_header')
			if $header.length
				$headerPosition = Math.round $header.position().top
				offset = 20
				$win.on 'scroll', =>
					scrollTop = document.scrollingElement.scrollTop
					if scrollTop  >= $headerPosition
						$('body').addClass('fixed-header')
					else
						$('body').removeClass('fixed-header')

					if scrollTop >= $headerPosition + offset
						$header.addClass('short') unless $header.hasClass('short')
					else
						$header.removeClass('short')

	openSharingPanel: ($event=null, mode=null) =>
		$event.preventDefault() if $event?
		if @rootScope.isSignedIn
			@rootScope.sharingPanelOpenAtScrollPoint = $(window).scrollTop()
			if @rootScope.profileDeactivated
				@confirm "You will need to reactivate your profile to share or rate an article", =>
					window.location.href = "/account-settings?reactivate=1"
				, null, "Please reactivate profile", ['Cancel', 'Reactivate']
			else if @rootScope.profileIncomplete
				@confirm "You cannot share or rate this article because you have not yet completed your profile", =>
					window.location.href = "/profile/new"
				, null, "Complete your profile", ['Cancel', 'Complete profile']
			else
				@rootScope.sharingPanelMode = mode if mode?
				tpl = $("#sharingPanel").html().trim()
				$content = @compile(tpl)(@scope)
				$('body').append $content
				$("#sharingPanelModal").modal()
		else
			@requiresSignIn("share or rate an article", window.location.pathname)

	updateMyFollowCounts: ->
		@http.get("/user_followings?counts=1").then (response) =>
			if response.data? and (response.data.status is 'success')
				@scope.followCounts = response.data.counts
				@scope.followCounts.loaded = true

	setTinyMceOptions: =>
		baseURL: "/tinymce-host"
		selector: 'textarea#comments'
		height: 56
		placeholder: "Add a comment..."
		statusbar: false
		menubar: false
		toolbar: false
		setup: (editor) =>
			@scope.currentTinyMceEditor = editor
		init_instance_callback: (ed) =>
			ed.on 'focus', (e) =>
				ed.theme.resizeTo('100%', 144)
			ed.on 'keydown', (e) =>
				if e.keyCode is 32
					curElm = ed.selection.getRng().startContainer
					caretPos = ed.selection.getBookmark(curElm.textContent).rng.startOffset
					if caretPos is curElm.textContent.length
						mkr = '<span class="marker">!</span>'
						ed.selection.setContent(mkr)
						newstr = ''
						c = ed.getContent({format : 'raw'}).split(mkr+"</span>")
						if !c[1]
							c = ed.getContent({format : 'raw'}).split(mkr+"<br></span>")
						if c[0] and c[1]
							newstr = c[0].replace(/^\s\s*/, '').replace(/\s\s*$/, '')+'</span>&nbsp;'+mkr+c[1].replace(/^\s\s*/, '').replace(/\s\s*$/, '').replace(/^[\s(&nbsp;]+/g,'')
							ed.setContent(newstr)
							e.preventDefault()
					marker = jQuery(ed.getBody()).find('.marker')
					ed.selection.select(marker.get(0))
					marker.remove()
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
				'<span class="mentioned_user" style="font-weight:bold;" data-user="' + item.id + '" data-display_name="' + item.displayname + '">' + item.username + '</span>';
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
