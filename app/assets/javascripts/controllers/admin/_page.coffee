class TheArticle.AdminPageController extends TheArticle.PageController
	constructor: ->
		super

	redirectToAdminPage: (page) =>
		window.location.href = "/admin/#{page}"