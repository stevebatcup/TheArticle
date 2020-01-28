class TheArticle.Follows extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$timeout'
	  '$compile'
	  '$ngConfirm'
	  '$sce'
	]

	init: ->
		@setDefaultHttpHeaders()
		@scope.userId = @element.data('user-id')
		@scope.isMe = @scope.userId is @element.data('current-user-id')
		@scope.follows =
			page: 1
			perPage: 50
			loaded: false
			totalItems: 0
			moreToLoad: false
			connectionsLoaded: false
			data:
				followings: []
				followers: []
				connections: []
				alsoKnowsMes: []
		vars = @getUrlVars()
		@scope.panelTab = if 'tab' of vars then vars['tab'] else 'following'
		@bindEvents()
		@timeout =>
			@getFollows()
		, 200

	bindEvents: =>
		super
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
			@scope.follows.totalItems = response.data.total if @scope.follows.page is 1
			@scope.follows.moreToLoad = @scope.follows.totalItems > (@scope.follows.page * @scope.follows.perPage)
			if @scope.follows.moreToLoad is true
				@loadMore()
			else
				if @scope.isMe
					@buildConnections()
				else
					@buildAlsoKnowsMes()
			@scope.follows.loaded = true

	inFollowers: (member) =>
		ids = _.map @scope.follows.data.followers, (item) =>
			item.id
		ids.indexOf(member.id) isnt -1

	buildConnections: =>
		results = []
		angular.forEach @scope.follows.data.followers, (item) =>
			results.push(item) if item.isConnected
		@scope.follows.data.connections = results
		@scope.follows.connectionsLoaded = true

	buildAlsoKnowsMes: =>
		results = []
		angular.forEach @scope.follows.data.followers, (item) =>
			results.push(item) if item.imFollowing
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
				@flash "You are no longer following <b>#{member.username}</b>"

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
				@flash "You are now following <b>#{member.username}</b>"

				followerItem.isConnected = true if followerItem
				@buildConnections()
			, false, false, =>
					@timeout =>
						member.imFollowing = false
					, 550

	setPanelTab: (tab) =>
		@scope.panelTab = tab

	closeFollowsPanel: =>
		@rootScope.$broadcast('follows_panel_close')

TheArticle.ControllerModule.controller('FollowsController', TheArticle.Follows)