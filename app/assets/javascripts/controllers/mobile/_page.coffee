class TheArticle.MobilePageController extends TheArticle.PageController
	constructor: ->
		super

	bindEvents: =>
		@bindCookieAcceptance()
		@bindSideMenu() if $('#mobile_side_menu').length
		@bindContactForm()
		@bindBlockClicks()
		@timeout =>
			@bindCarousels()
		, 300
		@bindSearchFilters()

		$(document).on 'show.bs.modal', (e) =>
			unless $(e.target).attr('id') is 'registerInterstitialModal'
				$('html').addClass('with_modal')
				@stopBodyScrolling(true)

		$(document).on 'hide.bs.modal', (e) =>
			unless $(e.target).attr('id') is 'registerInterstitialModal'
				$('html').removeClass('with_modal')
				@stopBodyScrolling(false)

		$('#open_feedback_form').on 'click', (e) =>
			@openFeedbackForm(e)

		$(document).on 'hidden.bs.modal', '#signinBoxModal', =>
			@rootScope.$broadcast 'sign_in_panel_closed'

	bindSideMenu: =>
		@rootScope.slideout = new Slideout
			'panel': document.getElementById('panel_for_side_menu')
			'menu': document.getElementById('mobile_side_menu')
			'padding': 256
			'tolerance': 70

		$(document).on 'click', '#sidebarCollapse', (e) =>
			e.preventDefault()
			@rootScope.slideout.toggle()

		$(document).on 'click', '.overlay.show_menu', (e) =>
			e.preventDefault()
			@rootScope.slideout.toggle()

		@rootScope.slideout.on 'beforeopen', (e, l) =>
			$('.overlay').addClass('show_menu').addClass('active')

		@rootScope.slideout.on 'beforeclose', (e, l) =>
			$('.overlay').removeClass('show_menu').removeClass('active')

	bindCarousels: =>
		isApp = @mobileAppDetected()
		docWidth = $(document).width()

		$(document).on 'init', '.slick-carousel', (e) =>
			window.setTimeout =>
				$(e.currentTarget).find('.inner').addClass('shown')
				$('.cloak').fadeIn('slow').removeClass('cloak')
			, 750

		$('.slick-carousel.articles').slick
			infinite: true
			slidesToShow: 1
			slidesToScroll: 1
			adaptiveHeight: true
			speed: 500
			arrows: false
			dots: if isApp or (docWidth > 370) then false else true
			centerMode: if isApp or (docWidth > 370) then true else false

		$('.slick-carousel.exchanges').slick
			infinite: true
			slidesToShow: 1
			slidesToScroll: 1
			adaptiveHeight: true
			speed: 500
			arrows: false
			dots: if isApp or (docWidth > 370) then false else false
			centerMode: if isApp or (docWidth > 370) then true else false

		$('.slick-carousel.journalists').slick
			infinite: true
			touchThreshold: 8
			slidesToScroll: 1
			adaptiveHeight: true
			speed: 500
			arrows: false
			centerMode: true
			slidesToShow: 1
			dots: false

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
			if @mobileAppDetected()
				urlVars = @getUrlVars()
				if 'sign_in' of urlVars
					window.location.reload()
				else
					window.location.href += "?sign_in=1"
			else
				@requiresSignIn("share or rate an article", window.location.pathname)

	disableDefaultBehaviour: (e) =>
		# console.log 'disableDefaultBehaviour'
		e.preventDefault()

	stopBodyScrolling: (stop) =>
		if stop
			# console.log 'stopBodyScrolling'
			document.body.addEventListener("touchmove", @disableDefaultBehaviour, false)
		else
			# console.log 'startBodyScrolling'
			document.body.removeEventListener("touchmove", @disableDefaultBehaviour, false)

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
			'nanospell' : '/tinymce-host/plugins/nanospell/plugin.js'
		content_css: [
			@element.data('tinymce-content-css-url'),
			'//fonts.googleapis.com/css?family=Montserrat'
		]
		nanospell_url: @scope.nanospellUrl

	openSearchPanel: ($event) =>
		$event.preventDefault()
		@rootScope.slideout.toggle() if @rootScope.slideout.isOpen()
		@timeout =>
			@rootScope.$broadcast 'search-clicked'

