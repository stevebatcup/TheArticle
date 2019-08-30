class TheArticle.AdminPageController extends TheArticle.PageController

	constructor: ->
		super

	createAccountPage: (user, $event) =>
		$event.preventDefault() if $event?
		unless _.contains @rootScope.userTabs, user
			@rootScope.userTabs.push user
			@http.get("/admin/create-account-page/#{user.id}").then (response) =>
				@openAccountPage(user)

	openAccountPage: (user, $event=null) =>
		$event.preventDefault() if $event?
		$(".user_account_page").hide()
		if _.contains @rootScope.pageBoxes, user.id
			$(".user_account_page[data-id=#{user.id}]").show()
		else
			@http.get("/admin/users/#{user.id}").then (response) =>
				userDetails = response.data
				console.log userDetails
				@openPageBox userDetails

	openPageBox: (userDetails) =>
		tpl = $("#user_account_html").html().trim()
		boxScope = @scope.$new(true)
		boxScope.userForBox = userDetails
		content = @compile(tpl)(boxScope)
		$('main.main-content').first().append content
		@rootScope.pageBoxes.push userDetails.id
		$(content).show()

	closeAccountPage: (user, $event=null) =>
		$event.preventDefault() if $event?
		@rootScope.userTabs = _.select @rootScope.userTabs, (item) =>
			item isnt user
		@http.get("/admin/close-page/#{user.id}").then (response) =>
			$(".user_account_page[data-id=#{user.id}]").remove()

	redirectToAdminPage: (page) =>
		window.location.href = "/admin/#{page}"