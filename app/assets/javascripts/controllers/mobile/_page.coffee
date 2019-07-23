class TheArticle.MobilePageController extends TheArticle.PageController
	constructor: ->
		super

	bindEvents: =>
		@bindCookieAcceptance()
		@bindSideMenu() if $('#mobile_side_menu').length
		@bindContactForm()
		@bindBlockClicks()
		setTimeout @bindCarousels, 800
		@bindSearchFilters()

		$(document).on 'show.bs.modal', =>
			$('html').addClass('with_modal')
			@stopBodyScrolling(true)

		$(document).on 'hide.bs.modal', =>
			$('html').removeClass('with_modal')
			@stopBodyScrolling(false)

		$('#open_feedback_form').on 'click', (e) =>
			@openFeedbackForm(e)

	# bindBlockClicks: =>
	# 	$(document).on 'click', '.block_click', (e) =>
	# 		@blockClick $(e.currentTarget), e
	# 	super

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
			dots: true
			centerMode: if $(window).width() <= 320 then false else true
			arrows: false

		$('.slick-carousel.exchanges').slick
			infinite: true
			slidesToShow: 1
			slidesToScroll: 1
			adaptiveHeight: true
			speed: 500
			dots: if $(window).width() <= 320 then true else false
			centerMode: if $(window).width() <= 320 then false else true
			arrows: false

		$('.slick-carousel.journalists').slick
			infinite: true
			slidesToShow: if $(window).width() <= 320 then 1 else 2
			slidesToScroll: 1
			adaptiveHeight: true
			speed: 300
			dots: if $(window).width() <= 320 then true else false
			arrows: false
			centerMode: true

	openSharingPanel: ($event=null, mode=null) =>
		$event.preventDefault() if $event?
		if @rootScope.isSignedIn
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
