class TheArticle.Follows extends TheArticle.MobilePageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$element'
	  '$timeout'
	  'EditorsPick'
	]

	init: ->
		@setDefaultHttpHeaders()
		@isMe = !@element.data('user-id')
		console.log @isMe
		@scope.follows =
			followings: []
			followers: []
		@getFollows()

	getFollows: =>
		url = if @isMe then "/user_followings" else "/user_followings/#{@element.data('user-id')}"
		@http.get(url).then (response) =>
			@scope.follows = response.data

	inFollowers: (member) =>
		ids = _.map @scope.follows.followers, (item) =>
			item.id
		ids.indexOf(member.id) isnt -1

	toggleFollowUserFromCard: (member) =>
		if member.imFollowing
			@unfollowUser member.id ,=>
				@scope.follows.followings = _.filter @scope.follows.followings, (item) =>
					item.id isnt member.id
				if followerItem = _.findWhere @scope.follows.followers, { id: member.id }
					followerItem.imFollowing = false
				member.imFollowing = false
		else
			@followUser member.id, =>
				member.imFollowing = true
				@scope.follows.followings.push member

	followUser: (userId, callback) =>
		@http.post("/user_followings", {id: userId}).then (response) =>
			callback.call(@)

	unfollowUser: (userId, callback) =>
		@http.delete("/user_followings/#{userId}").then (response) =>
			callback.call(@)

TheArticle.ControllerModule.controller('FollowsController', TheArticle.Follows)