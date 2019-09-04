class TheArticle.AdminPageController extends TheArticle.PageController

	constructor: ->
		super

	openSearchPage: ($event=null) =>
		$event.preventDefault() if $event?
		if window.location.pathname is "/admin/users"
			if $('.user_account_page:visible').length > 0
				@rootScope.openPageBoxId = 0
				$('.user_account_page:visible').hide()
		else
			window.location.href = "/admin/users"

	createAccountPage: (user, $event=null) =>
		$event.preventDefault() if $event?
		unless _.contains @rootScope.userTabs, user
			@rootScope.userTabs.push user
			@http.get("/admin/create-account-page/#{user.id}").then (response) =>
				@openAccountPage(user)

	openAccountPage: (user, $event=null) =>
		$event.preventDefault() if $event?
		$(".user_account_page").hide()
		@rootScope.openPageBoxId = user.id
		if _.contains @rootScope.pageBoxes, user.id
			$(".user_account_page[data-id=#{user.id}]").show()
		else
			@http.get("/admin/users/#{user.id}").then (response) =>
				userDetails = response.data
				@openPageBox userDetails

	openPageBox: (userDetails) =>
		tpl = $("#user_account_html").html().trim()
		boxScope = @scope.$new(true)
		boxScope.userForBox = userDetails
		content = @compile(tpl)(boxScope)
		$('main.main-content').first().append content
		@rootScope.pageBoxes.push userDetails.id
		$(content).show()
		@loadFullUserDetails(boxScope.userForBox)

	loadFullUserDetails: (scopedUser) =>
		@http.get("/admin/users/#{scopedUser.id}?full_details=1").then (response) =>
			angular.forEach response.data, (value, key) =>
				scopedUser[key] = value
			# @getProfilePreview(scopedUser)

	getProfilePreview: (scopedUser) =>
		@http.defaults.headers.common['Accept'] = 'text/html'
		@http.defaults.headers.common['Content-Type'] = 'text/html'
		@http.defaults.headers.common['X-MobileApp'] = 1
		@http.get(scopedUser.profileUrl, { responseType: 'blob' }).then (response) =>
			dataUrl = URL.createObjectURL(response.data)
			$("iframe[data-user-id=#{scopedUser.id}]").attr('src', dataUrl)

	closeAccountPage: (user, $event=null) =>
		$event.preventDefault() if $event?
		@rootScope.openPageBoxId = 0
		@rootScope.userTabs = _.select @rootScope.userTabs, (item) =>
			item isnt user
		@http.get("/admin/close-page/#{user.id}").then (response) =>
			$(".user_account_page[data-id=#{user.id}]").remove()

	redirectToAdminPage: (page) =>
		window.location.href = "/admin/#{page}"