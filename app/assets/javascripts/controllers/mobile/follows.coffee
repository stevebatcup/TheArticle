class TheArticle.Follows extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	  '$element'
	  '$timeout'
	  'EditorsPick'
	]

	init: ->
		@setDefaultHttpHeaders()
		@scope.userId = @element.data('user-id')
		@scope.isMe = @scope.userId is @element.data('current-user-id')
		@scope.follows =
			followings: []
			followers: []
		@scope.myFollows =
			followings: []
			followers: []
		@scope.panelTab = 'following'
		@bindEvents()
		@getFollows(false)
		@getFollows(true) if !@scope.isMe

	bindEvents: =>
		@scope.$on 'follows_panel_open', (data, tab) =>
			@scope.panelTab = tab

	getFollows: (isMe) =>
		url = if isMe then "/user_followings" else "/user_followings/#{@scope.userId}"
		@http.get(url).then (response) =>
			if isMe
				@scope.myFollows = response.data
			else
				@scope.follows = response.data

	inFollowers: (member) =>
		ids = _.map @scope.follows.followers, (item) =>
			item.id
		ids.indexOf(member.id) isnt -1

	inMyFollowers: (member) =>
		ids = _.map @scope.myFollows.followers, (item) =>
			item.id
		ids.indexOf(member.id) isnt -1

	toggleFollowUserFromCard: (member) =>
		if member.imFollowing
			@unfollowUser member.id, =>
				if @scope.isMe
					@scope.follows.followings = _.filter @scope.follows.followings, (item) =>
						item.id isnt member.id
				if followingItem = _.findWhere @scope.follows.followings, { id: member.id }
					followingItem.imFollowing = false
				if followerItem = _.findWhere @scope.follows.followers, { id: member.id }
					followerItem.imFollowing = false
		else
			@followUser member.id, =>
				if @scope.isMe
					@scope.follows.followings.push member
				if followingItem = _.findWhere @scope.follows.followings, { id: member.id }
					followingItem.imFollowing = true
				if followerItem = _.findWhere @scope.follows.followers, { id: member.id }
					followerItem.imFollowing = true
			, false

	setPanelTab: (tab) =>
		@scope.panelTab = tab

	closeFollowsPanel: =>
		@rootScope.$broadcast('follows_panel_close')

TheArticle.ControllerModule.controller('FollowsController', TheArticle.Follows)