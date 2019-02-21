class TheArticle.Feeds extends TheArticle.PageController

	@register window.App
	@$inject: [
	  '$scope'
	  '$timeout'
	  'Comment'
	  'Opinion'
	]

	listenForActions: =>
		@scope.$on 'report_profile', ($event, data) =>
			@reportProfile($event, data.profile)

		@scope.$on 'mute', ($event, data) =>
			@mute($event, data.userId, data.username)

		@scope.$on 'unmute', ($event, data) =>
			@unmute($event, data.userId, data.username)

		@scope.$on 'block', ($event, data) =>
			@block($event, data.userId, data.username)

		@scope.$on 'unblock', ($event, data) =>
			@unblock($event, data.userId, data.username)

		@scope.$on 'unfollow', ($event, data) =>
			@unfollow($event, data.userId, data.username)

	feedActionRequiresSignIn: ($event, action) =>
		$event.preventDefault()
		@requiresSignIn(action)

	showRequiresConnectionInfo: ($event, item) =>
		$event.preventDefault()
		item.actionAuthError = false
		@scope.itemForConnectionMessage = item
		# console.log @scope.itemForConnectionMessage.canInteract
		@timeout =>
			tpl = $("#requiresConnectionInfoBox").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#requiresConnectionInfoBoxModal").modal()
		, 350

	pluralize: (count, single, multipleOrZero) =>
		if count is 1
			"#{count} #{single}"
		else
			"#{count} #{multipleOrZero}"

	replyToComment: ($event, comment, parentComment, replyingToReply=false) =>
		$event.preventDefault()
		$commentsPane = $($event.target).closest('.comments_pane')
		@scope.replyingToComment =
			comment: comment
			parentComment: parentComment.data
			replyingToReply: replyingToReply
		$commentBox = $(".comment-item[data-comment-id=#{comment.data.id}]", $commentsPane)
		$replyBox = $commentsPane.find('.respond')
		$replyBox.find('a.cancel_reply', $replyBox).show()
		$textarea = $replyBox.find('textarea')
		$textarea.attr('placeholder', 'Reply to Comment')
		$replyBox.data('comment-id', comment.data.id).attr('data-comment-id', comment.data.id)
		$replyBox.detach().appendTo($commentBox.parent())
		$textarea.focus()

	filterCommentsByLimit: (item) =>
		if item.share.commentShowLimit > 0
			item.comments.slice(0, item.share.commentShowLimit)
		else
			item.comments

	filterRepliesByLimit: (comment, item) =>
		if comment.data.replyShowLimit > 0
			comment.children.slice(0, comment.data.replyShowLimit)
		else
			comment.children

	commentCount: (item, with_sentence=true) =>
		if item.share.commentsLoaded
			count = item.comments.length
		else
			count = item.share.commentCount
		if with_sentence
			@pluralize(count, 'comment', 'comments')
		else
			count

	followUserFromCommentAuthError: ($event, item) =>
		$event.preventDefault()
		@followUserFromAuthError item, =>
			@showComments()

	followUserFromAuthError: ($event=null, item, canThenInteract=false) =>
		$event.preventDefault() if $event?
		@followUser item.share.user.id, =>
			if canThenInteract is true
				item.canInteract = 'yes'
				if item.actionForRetry is 'comment'
					@showComments($event, item, true)
				if item.actionForRetry is 'agree'
					@agreeWithPost($event, item)
				if item.actionForRetry is 'disagree'
					@disagreeWithPost($event, item)
				item.actionForRetry = false
			else
				item.canInteract = 'not_followed'
				@flash "You are now following <b>#{item.share.user.displayName}</b>"
			item.actionAuthError = false

	showComments: ($event=null, item, startWriting=false) =>
		$event.preventDefault() if $event?
		item.actionAuthError = false
		if @scope.isSignedIn is false
			@requiresSignIn('view comments')
		else if (item.canInteract is 'not_followed') and (startWriting is true)
			item.actionAuthError = 'not_followed'
		else if (item.canInteract is 'not_following') and (startWriting is true)
			item.actionAuthError = 'not_following'
			item.actionForRetry = 'comment'
		else if (item.canInteract isnt 'yes') and (startWriting is true)
			item.actionAuthError = 'not_connected'
		else
			if !item.share.commentsLoaded
				@Comment.query({share_id: item.share.id, order_by: item.orderCommentsBy}).then (comments) =>
						item.comments = comments
						@showCommentsSuccess(item, startWriting, $event)
						@timeout =>
							item.share.commentsLoaded = true
						, 750
			else
				@showCommentsSuccess(item, startWriting, $event)

	commentOrderText: (orderCommentsBy) =>
		switch orderCommentsBy
			when 'most_relevant' then 'Most relevant'
			when 'most_recent' then 'Most recent'
			when 'oldest' then 'Oldest'

	reorderComments: ($event, item, orderCommentsBy) =>
		$event.preventDefault() if $event?
		item.orderCommentsBy = orderCommentsBy
		@resetComments(item)

	resetComments: (item) =>
		item.share.commentsLoaded = false
		@showComments(null, item)

	showCommentsSuccess: (item, focusTextBox, $event) =>
		item.share.showComments = true
		item.share.showAgrees = false
		item.share.showDisagrees = false
		if focusTextBox and (@scope.isSignedIn is true)
			@timeout =>
				$($event.target).closest('.feed-share').find('textarea.comment_textarea').focus()
			, 500

	showAllComments: ($event, item) =>
		$event.preventDefault()
		item.share.commentShowLimit = 0

	showAllReplies: ($event, comment) =>
		$event.preventDefault()
		comment.data.replyShowLimit = 0

	cancelReply: ($event, shareId) =>
		$event.preventDefault()
		$commentsPane = $($event.target).closest('.comments_pane')
		@scope.replyingToComment =
			comment: {}
			parentComment: {}
			replyingToReply: false
		$replyBox = $(".respond[data-share-id=#{shareId}]", $commentsPane)
		$replyBox.find('a.cancel_reply', $replyBox).hide()
		$replyBox.find('textarea').attr('placeholder', 'Add your Comment')
		$replyBox.data('comment-id', 0).attr('data-comment-id', 0)
		$replyBox.detach().prependTo $commentsPane

	postComment: ($event, post) =>
		$event.preventDefault()
		$replyBox = $(".respond[data-share-id=#{post.share.id}]")
		replyingToCommentId = Number($replyBox.data('comment-id'))
		replyingToUsername = if @scope.replyingToComment.replyingToReply then @scope.replyingToComment.comment.data.username else ''
		parentId = if 'id' of @scope.replyingToComment.parentComment then @scope.replyingToComment.parentComment.id else 0
		new @Comment
			share_id: post.share.id
			body: @scope.commentForSubmission.value
			parent: parentId
			replying_to_username: replyingToUsername
		.create().then (comment) =>
			if comment.status is 'success'
				if replyingToCommentId is 0
					post.comments.push { data: comment }
				else
					angular.forEach post.comments, (rootComment) =>
						if rootComment is @scope.replyingToComment.comment
							unless 'children' of rootComment
								rootComment.children = []
							rootComment.children.push { data: comment }
						else
							angular.forEach rootComment.children, (childComment) =>
								if childComment is @scope.replyingToComment.comment
									rootComment.children.push { data: comment }
				@scope.commentForSubmission.value = ''
				@cancelReply $event, post.share.id
			else
				@alert comment.message

	agreeCount: (item, with_sentence=true) =>
		if item.share.opinionsLoaded
			count = item.opinions.agrees.length
		else
			count = item.share.agreeCount
		if with_sentence
			@pluralize(count, 'person agrees', 'people agree')
		else
			count

	showAgrees: ($event=null, item) =>
		$event.preventDefault() if $event?
		if @scope.isSignedIn is true
			item.actionAuthError = false
			if !item.share.opinionsLoaded
				@loadOpinions item, =>
					@showAgreesSuccess(item)
			else
				@showAgreesSuccess(item)
		else
			@requiresSignIn('interact with this post')


	showAgreesSuccess: (item) =>
		item.share.showAgrees = true
		item.share.showDisagrees = false
		item.share.showComments = false

	showAllAgrees: ($event, item) =>
		$event.preventDefault()
		item.share.agreeShowLimit = 0

	filterAgreesByLimit: (item) =>
		if item.share.agreeShowLimit > 0
			item.opinions.agrees.slice(0, item.share.agreeShowLimit)
		else
			item.opinions.agrees

	agreeWithPost: ($event=null, item) =>
		$event.preventDefault() if $event?
		if @scope.isSignedIn is false
			@requiresSignIn('interact with this post')
		else if item.canInteract is 'not_followed'
			item.actionAuthError = 'not_followed'
		else if item.canInteract is 'not_following'
			item.actionAuthError = 'not_following'
			item.actionForRetry = 'agree'
		else if item.canInteract isnt 'yes'
			item.actionAuthError = 'not_connected'
		else
			if !item.share.opinionsLoaded
				@loadOpinions item, =>
					@agreeWithPostSubmit(item)
			else
				@agreeWithPostSubmit(item)

	agreeWithPostSubmit: (item) =>
		action = if item.iAgreeWithPost is true then 'unagree' else 'agree'
		new @Opinion
			share_id: item.share.id
			action: action
		.create().then (opinion) =>
			if opinion.status is 'success'
				if action is 'unagree'
					# un-agree
					item.opinions.agrees = _.filter item.opinions.agrees, (agree) =>
						agree.user.id isnt opinion.user.id
					item.iAgreeWithPost = false
				else
					# agree
					item.opinions.agrees.push
						user:
							id: opinion.user.id
							displayName: opinion.user.displayName
							username: opinion.user.username
							image: opinion.user.image
					item.opinions.disagrees = _.filter item.opinions.disagrees, (disagree) =>
						disagree.user.id isnt opinion.user.id
					item.iAgreeWithPost = true
					item.iDisagreeWithPost = false

	disagreeCount: (item, with_sentence=true) =>
		if item.share.opinionsLoaded
			count = item.opinions.disagrees.length
		else
			count = item.share.disagreeCount
		if with_sentence
			@pluralize(count, 'person disagrees', 'people disagree')
		else
			count

	showDisagrees: ($event=null, item) =>
		$event.preventDefault() if $event?
		if @scope.isSignedIn is true
			item.actionAuthError = false
			if !item.share.opinionsLoaded
				@loadOpinions item, =>
					@showDisagreesSuccess(item)
			else
				@showDisagreesSuccess(item)
		else
			@requiresSignIn('interact with this post')

	showDisagreesSuccess: (item) =>
		item.share.showDisagrees = true
		item.share.showAgrees = false
		item.share.showComments = false

	showAllDisagrees: ($event, item) =>
		$event.preventDefault()
		item.share.disagreeShowLimit = 0

	filterDisagreesByLimit: (item) =>
		if item.share.disagreeShowLimit > 0
			item.opinions.disagrees.slice(0, item.share.disagreeShowLimit)
		else
			item.opinions.disagrees

	disagreeWithPost: ($event=null, item) =>
		$event.preventDefault() if $event?
		if @scope.isSignedIn is false
			@requiresSignIn('interact with this post')
		else if item.canInteract is 'not_followed'
			item.actionAuthError = 'not_followed'
		else if item.canInteract is 'not_following'
			item.actionAuthError = 'not_following'
			item.actionForRetry = 'disagree'
		else if item.canInteract isnt 'yes'
			item.actionAuthError = 'not_connected'
		else
			if !item.share.opinionsLoaded
				@loadOpinions item, =>
					@disagreeWithPostSubmit(item)
			else
				@disagreeWithPostSubmit(item)

	disagreeWithPostSubmit: (item) =>
		action = if item.iDisagreeWithPost is true then 'undisagree' else 'disagree'
		new @Opinion
			share_id: item.share.id
			action: action
		.create().then (opinion) =>
			if opinion.status is 'success'
				if action is 'undisagree'
					# un-disagree
					item.opinions.disagrees = _.filter item.opinions.disagrees, (disagree) =>
						disagree.user.id isnt opinion.user.id
					item.iDisagreeWithPost = false
				else
					# disagree
					item.opinions.disagrees.push
						user:
							id: opinion.user.id
							displayName: opinion.user.displayName
							username: opinion.user.username
							image: opinion.user.image
					item.opinions.agrees = _.filter item.opinions.agrees, (agree) =>
						agree.user.id isnt opinion.user.id
					item.iDisagreeWithPost = true
					item.iAgreeWithPost = false

	loadOpinions: (item, callback=null) =>
		@Opinion.query({share_id: item.share.id}).then (opinions) =>
			item.opinions = opinions
			callback.call(@)
			@timeout =>
				item.share.opinionsLoaded = true
			, 750

	followUserFromNoConnectionModal: (item, $event, canThenInteract=true) =>
		$event.preventDefault()
		@followUser item.share.user.id, =>
			$('button[data-dismiss=modal]', "#requiresConnectionInfoBoxModal").click()
			@timeout =>
				if canThenInteract
					item.canInteract = 'yes'
				else
					item.canInteract = 'not_followed'
			, 750

	reportProfile: ($event, profile) =>
		$event.preventDefault()
		if @scope.isSignedIn is false
			@requiresSignIn('report this profile')
		else
			@openConcernReportModal('profile', profile)

	reportPost: ($event, item) =>
		$event.preventDefault()
		if @scope.isSignedIn is false
			@requiresSignIn('report this post')
		else
			item = item.share if _.contains(['commentAction', 'opinionAction'], item.type)
			@openConcernReportModal('post', item)

	reportCommentAction: ($event=null, item) =>
		$event.preventDefault() if $event?
		if @scope.isSignedIn is false
			@requiresSignIn('report this comment')
		else
			@openConcernReportModal('commentAction', item)

	reportComment: ($event=null, item) =>
		$event.preventDefault() if $event?
		if @scope.isSignedIn is false
			@requiresSignIn('report this comment')
		else
			@openConcernReportModal('comment', item)

	openConcernReportModal: (type='post', resource) =>
		# console.log resource
		if @rootScope.concernReportModal
			@rootScope.concernReportModal.modal('show')
		else
			tpl = $("#concernReport").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			@rootScope.concernReportModal = $("#concernReportModal").modal()
		@timeout =>
			@rootScope.$broadcast 'init_concern_report', { type: type, resource: resource }
		, 250

	mute: ($event, userId, username) =>
		$event.preventDefault()
		if @scope.isSignedIn is false
			@requiresSignIn('mute a profile')
		else
			@http.post("/mutes", {id: userId}).then (response) =>
				@reloadPageWithFlash("You have muted <b>#{username}</b>", 'unmute')

	unmute: ($event, userId, username) =>
		$event.preventDefault()
		@http.delete("/mutes/#{userId}").then (response) =>
			@reloadPageWithFlash("You have unmuted <b>#{username}</b>", 'mute')

	block: ($event=null, userId, username) =>
		$event.preventDefault() if $event?
		if @scope.isSignedIn is false
			@requiresSignIn('block a profile')
		else
			@scope.confirmingBlock =
				user:
					id: userId
					username: username
			tpl = $("#confirmBlock").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#confirmBlockModal").modal()

	confirmBlock: ($event, user) =>
		@http.post("/blocks", {id: user.id}).then (response) =>
			$("#confirmBlockModal").modal('hide')
			@reloadPageWithFlash("You have blocked <b>#{user.username}</b>", 'unblock')

	unblock: ($event, userId, username) =>
		$event.preventDefault()
		confirmMsg = "#{username} will be able to follow you and message you.  <a href='/help?section=blocking'>Read more</a> about what it means to block and unblock someone."
		@confirm confirmMsg, =>
			@http.delete("/blocks/#{userId}").then (response) =>
				@reloadPageWithFlash("You have unblocked <b>#{username}</b>", 'block')
		, null, "Unblock #{username}?", ["Cancel", "Unblock"]

	unfollow: ($event, userId, username) =>
		$event.preventDefault()
		@http.delete("/user_followings/#{userId}").then (response) =>
			@reloadPageWithFlash("You have unfollowed <b>#{username}</b>", 'block')

	deleteOwnComment: ($event, item, comment, parent=null) =>
		$event.preventDefault()
		msg = "You are about to delete your own comment, along with any replies to that comment. Are you sure?"
		@confirm msg, =>
			@deleteComment comment, 'own', null, =>
				if parent?
					parent.children = _.filter parent.children, (c) =>
						c.data.id isnt comment.data.id
				else
					item.comments = _.filter item.comments, (c) =>
						c.data.id isnt comment.data.id
				@flash "Comment deleted"
		, null, 'Delete your comment', ['Cancel', 'Delete']

	deleteOthersComment: ($event, item, comment, parent=null) =>
		$event.preventDefault()
		@scope.dataForCommentDeletion =
			item: item
			comment: comment
			parent: parent
		tpl = $("#deleteOthersComment").html().trim()
		$content = @compile(tpl)(@scope)
		$('body').append $content
		$("#deleteOthersCommentModal").modal()

	deleteCommentFromModal: ($event, item, comment, parent=null) =>
		@deleteComment comment, 'theirs', comment.data.deleteReason, =>
			$("#deleteOthersCommentModal").modal('hide')
			@timeout =>
				if parent?
					parent.children = _.filter parent.children, (c) =>
						c.data.id isnt comment.data.id
				else
					item.comments = _.filter item.comments, (c) =>
						c.data.id isnt comment.data.id
				@flash "Comment deleted"
				comment.data.deleteReason = false

				if comment.data.deleteAlsoBlock is true
					@block(null, comment.data.userId, comment.data.username)
					comment.data.deleteAlsoBlock = false

				if comment.data.deleteAlsoReport is true
					@reportComment(null, comment.data)
					comment.deleteAlsoReport = false

				@scope.dataForCommentDeletion = {}
			, 350

	deleteComment: (comment, ownership='own', reason=null, callback=null) =>
		url = "/delete-comment?id=#{comment.data.id}&ownership=#{ownership}"
		url += "&reason=#{reason}" if reason?
		@http.delete(url).then (response) =>
			if response.data.status is 'success'
				callback.call(@) if callback?
			else
				@alert response.data.message, "Error deleting comment"
		, (error) =>
			@alert "Sorry there was an error deleting this comment, please try again.", "Error deleting comment"

	deleteMyPost: ($event, share) =>
		$event.preventDefault()
		msg = "Are you sure you wish to delete this post?"
		@confirm msg, =>
			@http.delete("/delete-share?id=#{share.id}").then (response) =>
				if response.data.status is 'success'
					window.location.reload()
				else
					@alert response.data.message, "Error deleting post"
			, (error) =>
				@alert "Sorry there was an error deleting this post, please try again.", "Error deleting post"
		, null, 'Delete your post', ['Cancel', 'Delete']

	expandThirdPartySharingTextarea: ($event) =>
		$textarea = $($event.target)
		$textarea.addClass('expanded').attr('placeholder', 'What are you reading? Post a link to any published article you would like to share on your public profile.')

	contractThirdPartySharingTextarea: ($event) =>
		$textarea = $($event.target)
		$textarea.removeClass('expanded').attr('placeholder', 'What are you reading?')

	openThirdPartySharingPanelIfEnterPressed: ($event) =>
		if $('textarea#third_party_article_url_phantom').val().length > 10
			url = $('textarea#third_party_article_url_phantom').val()
			@openThirdPartySharingPanel(url) if $event.keyCode is 13

	openThirdPartySharingPanelFromPaste: ($event) =>
		url = $event.originalEvent.clipboardData.getData('text/plain')
		@openThirdPartySharingPanel(url)

	openThirdPartySharingPanel: (url) =>
		if $("#thirdPartySharingModal").length > 0
			$("#thirdPartySharingModal").modal('show')
		else
			tpl = $("#thirdPartySharing").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#thirdPartySharingModal").modal()

		$(document).off 'shown.bs.modal', '#thirdPartySharingModal'
		$(document).off 'hide.bs.modal', '#thirdPartySharingModal'
		$(document).on 'shown.bs.modal', '#thirdPartySharingModal', =>
			@timeout =>
				@rootScope.$broadcast 'third_party_url_sharing', { url: url }
			, 500
		$(document).on 'hide.bs.modal', '#thirdPartySharingModal', =>
			@rootScope.$broadcast 'third_party_url_close', { url: url }
			$('textarea#third_party_article_url_phantom').val('')

	muteFollowed: ($event, item) =>
		$event.preventDefault()
		@http.get("/mute-followed/#{item.followed.id}").then (response) =>
			$($event.target).closest('.feed-listing').remove()

	muteExchange: ($event, item) =>
		$event.preventDefault()
		@http.get("/mute-exchange/#{item.id}").then (response) =>
			$($event.target).closest('.feed-listing').remove()

	showAllMyFollowersOfUser: (id) =>
		@http.get("/my-followers-of-user/#{id}").then (response) =>
			@scope.myFollowersOf = response.data
			tpl = $("#myFollowersOf").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#myFollowersOfModal").modal()

	showAllMyFollowersOfExchange: (id) =>
		@http.get("/my-followers-of-exchange/#{id}").then (response) =>
			@scope.myFollowersOf = response.data
			tpl = $("#myFollowersOf").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#myFollowersOfModal").modal()

TheArticle.ControllerModule.controller('FeedsController', TheArticle.Feeds)