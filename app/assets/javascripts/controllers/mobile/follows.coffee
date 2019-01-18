class TheArticle.Follows extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$timeout'
	  '$compile'
	]

	init: ->
		# console.log 'init follows'
		@setDefaultHttpHeaders()
		@scope.userId = @element.data('user-id')
		@scope.isMe = @scope.userId is @element.data('current-user-id')
		# console.log @scope.isMe
		@scope.follows =
			page: 1
			perPage: 10
			loaded: false
			totalItems: 0
			moreToLoad: false
			data:
				followings: []
				followers: []
				connections: []
				alsoKnowsMes: []
		@scope.panelTab = 'following'
		@bindEvents()
		@getFollows()

	bindEvents: =>
		@scope.$on 'follows_panel_open', (data, tab) =>
			@scope.panelTab = tab

	loadMore: =>
		@scope.follows.page += 1
		@getFollows()

	getFollows: =>
		url = "/user_followings/#{@scope.userId}?page=#{@scope.follows.page}&per_page=#{@scope.follows.perPage}"
		@http.get(url).then (response) =>
			angular.forEach response.data.list.followings, (item) =>
				@scope.follows.data.followings.push item
			angular.forEach response.data.list.followers, (item) =>
				@scope.follows.data.followers.push item
			# console.log @scope.follows.data
			@scope.follows.totalItems = response.data.total if @scope.follows.page is 1
			# console.log @scope.follows.totalItems
			@scope.follows.moreToLoad = @scope.follows.totalItems > (@scope.follows.page * @scope.follows.perPage)
			# console.log @scope.follows.moreToLoad
			@scope.follows.loaded = true
			if @scope.follows.moreToLoad is true
				@loadMore()
			else
				if @scope.isMe
					@buildConnections()
				else
					@buildAlsoKnowsMes()

	inFollowers: (member) =>
		ids = _.map @scope.follows.data.followers, (item) =>
			item.id
		ids.indexOf(member.id) isnt -1

	buildConnections: =>
		results = []
		angular.forEach @scope.follows.data.followers, (item) =>
			results.push(item) if item.isConnected
		@scope.follows.data.connections = results

	buildAlsoKnowsMes: =>
		results = []
		angular.forEach @scope.follows.data.followers, (item) =>
			results.push(item) if item.isFollowingMe
		@scope.follows.data.alsoKnowsMes = results

	toggleFollowUserFromCard: (member) =>
		if member.imFollowing
			@unfollowUser member.id, =>
				if @scope.isMe
					@scope.follows.data.followings = _.filter @scope.follows.data.followings, (item) =>
						item.id isnt member.id
				if followingItem = _.findWhere @scope.follows.data.followings, { id: member.id }
					followingItem.imFollowing = false
				if followerItem = _.findWhere @scope.follows.data.followers, { id: member.id }
					followerItem.imFollowing = false

				followerItem.isConnected = false if followerItem
				@buildConnections()
		else
			@followUser member.id, =>
				if @scope.isMe
					@scope.follows.data.followings.push member
				if followingItem = _.findWhere @scope.follows.data.followings, { id: member.id }
					followingItem.imFollowing = true
				if followerItem = _.findWhere @scope.follows.data.followers, { id: member.id }
					followerItem.imFollowing = true

				followerItem.isConnected = true if followerItem
				@buildConnections()
			, false

	setPanelTab: (tab) =>
		@scope.panelTab = tab

	closeFollowsPanel: =>
		@rootScope.$broadcast('follows_panel_close')

TheArticle.ControllerModule.controller('FollowsController', TheArticle.Follows)