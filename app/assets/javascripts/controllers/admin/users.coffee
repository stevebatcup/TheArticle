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
			query: ''
			refiner: ''
			dateFrom: new Date(@element.data('start-date'))
			dateTo: new Date(@element.data('end-date'))
		@setDefaultHttpHeaders()
		@scope.records =
			perPage: Number(@element.data('records-per-page'))
		@watch()
		@runSearch(null)

	watch: =>
		@scope.$watch 'records.perPage', (newVal, oldVal) =>
			if (newVal isnt oldVal) and newVal > 0
				@http.get("/admin/set_users_per_page?per_page=#{newVal}").then (response) =>
					window.location.reload()

	runSearch: ($event) =>
		$event.preventDefault() if $event?
		dateFrom = @scope.searchFields.dateFrom.toISOString().substring(0, 10)
		dateTo = @scope.searchFields.dateTo.toISOString().substring(0, 10)
		url = "/admin/users?date_from=#{dateFrom}&date_to=#{dateTo}"
		url += "&search=#{@scope.searchFields.query}" if @scope.searchFields.query.length > 1
		url += "&refiner=#{@scope.searchFields.refiner}" if @scope.searchFields.refiner.length > 0
		console.log url
		@http.get(url).then (response) =>
			console.log "@scope.users"
			@scope.users = response.data.users

TheArticle.ControllerModule.controller('UsersController', TheArticle.Users)