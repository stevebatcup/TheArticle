class TheArticle.Users extends TheArticle.AdminPageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
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
			loaded: false
			page: 1
			perPage: @element.data('records-per-page')
			totalPages: 0
			totalRecords: 0
			sort: 'id'
			dir: 'desc'
			query: ''
			refiner: ''
			dateFrom: new Date(@element.data('start-date') + ' 00:00:00')
			dateTo: new Date(@element.data('end-date') + ' 00:00:00')
		@setDefaultHttpHeaders()
		@runSearch(null)

	setPerPage: =>
		@scope.searchFields.page = 1
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
		dateFrom = new Date(@scope.searchFields.dateFrom.getTime() - (@scope.searchFields.dateFrom.getTimezoneOffset() * 60000)).toISOString().substring(0, 10)
		dateTo = new Date(@scope.searchFields.dateTo.getTime() - (@scope.searchFields.dateTo.getTimezoneOffset() * 60000)).toISOString().substring(0, 10)
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

		@scope.searchFields.loaded = false
		@http.get(url).then (response) =>
			@scope.searchFields.loaded = true
			@scope.users = response.data.users
			if @scope.searchFields.page is 1
				@scope.searchFields.totalPages = response.data.totalPages
				@scope.searchFields.totalRecords = response.data.totalRecords

TheArticle.ControllerModule.controller('UsersController', TheArticle.Users)