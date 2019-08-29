class TheArticle.Users extends TheArticle.AdminPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$element'
	  '$compile'
	  '$timeout'
	  '$compile'
	  '$ngConfirm'
	]

	init: ->
		@scope.users = []
		@scope.searchFields =
			page: 1
			perPage: @element.data('records-per-page')
			totalPages: 0
			sort: 'id'
			dir: 'desc'
			query: ''
			refiner: ''
			dateFrom: new Date(@element.data('start-date'))
			dateTo: new Date(@element.data('end-date'))
		@setDefaultHttpHeaders()
		@runSearch(null)

	setPerPage: =>
		@runSearch(null)

	reorder: ($event, sortBy) =>
		@scope.searchFields.page = 1
		if sortBy is @scope.searchFields.sort
			@scope.searchFields.dir = if @scope.searchFields.dir is 'asc' then 'desc' else 'asc'
		else
			@scope.searchFields.dir = if sortBy is 'id' then 'desc' else 'asc'
		@scope.searchFields.sort = sortBy
		@runSearch($event)

	paginate: =>
		@runSearch(null)

	prevPage: ($event, page) =>
		@scope.searchFields.page -= 1
		@runSearch($event)

	nextPage: ($event, page) =>
		@scope.searchFields.page += 1
		@runSearch($event)

	firstPage: ($event, page) =>
		@scope.searchFields.page = 1
		@runSearch($event)

	lastPage: ($event, page) =>
		@scope.searchFields.page = @scope.searchFields.totalPages
		@runSearch($event)

	runSearch: ($event) =>
		$event.preventDefault() if $event?
		dateFrom = @scope.searchFields.dateFrom.toISOString().substring(0, 10)
		dateTo = @scope.searchFields.dateTo.toISOString().substring(0, 10)
		data =
			date_from: dateFrom
			date_to: dateTo
			sort: @scope.searchFields.sort
			dir: @scope.searchFields.dir
			page: @scope.searchFields.page
			per_page: @scope.searchFields.perPage
		data['search'] = @scope.searchFields.query if @scope.searchFields.query.length > 1
		data['refiner'] = @scope.searchFields.refiner if @scope.searchFields.refiner.length > 0

		url = "/admin/users?1&" + $.param(data)
		console.log url

		@http.get(url).then (response) =>
			@scope.users = response.data.users
			@scope.searchFields.totalPages = response.data.totalPages if @scope.searchFields.page is 1






TheArticle.ControllerModule.controller('UsersController', TheArticle.Users)