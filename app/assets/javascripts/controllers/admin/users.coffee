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
		@scope.searchFields =
			query: ''
			refiner: ''
			dateFrom: new Date(@element.data('start-date'))
			dateTo: new Date(@element.data('end-date'))
		@setDefaultHttpHeaders()
		@scope.records =
			perPage: Number(@element.data('records-per-page'))
		@watch()

	watch: =>
		@scope.$watch 'records.perPage', (newVal, oldVal) =>
			if (newVal isnt oldVal) and newVal > 0
				@http.get("/admin/set_users_per_page?per_page=#{newVal}").then (response) =>
					window.location.reload()

	runSearch: ($event) =>
		$event.preventDefault() if $event?
		if @scope.searchFields.query.length > 2
			dateFrom = @scope.searchFields.dateFrom.toISOString().substring(0, 10)
			dateTo = @scope.searchFields.dateTo.toISOString().substring(0, 10)
			url = "/admin/users?query=#{@scope.searchFields.query}&refiner=#{@scope.searchFields.refiner}&date_from=#{dateFrom}&date_to=#{dateTo}"
			@http.get url, (response) =>
				console.log response.data

TheArticle.ControllerModule.controller('UsersController', TheArticle.Users)