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

		@scope.$on 'opinion_on_feed_item', ($event, data) =>
			@updateAllSharesWithOpinion(data.share_id, data.action, data.user) if 'updateAllSharesWithOpinion' of @

	feedActionRequiresSignIn: ($event, action) =>
		$event.preventDefault()
		@requiresSignIn(action, window.location.pathname)

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

	replyToComment: ($event, comment, parentComment, replyingToReply=false, item) =>
		$event.preventDefault()
		$commentsPane = angular.element($event.target).closest('.comments_pane')

		@scope.replyingToComment =
			comment: comment
			parentComment: parentComment.data
			replyingToReply: replyingToReply

		$mainCommentBox = angular.element(".respond[data-share-id=#{item.share.id}]", $commentsPane)
		$mainCommentBox.removeClass('with_form').html('')

		$commentBox = angular.element(".comment-item[data-comment-id=#{comment.data.id}]", $commentsPane)

		tpl = angular.element("#commentForm").html()
		$commentRespond = angular.element(".comment_respond", $commentBox)
		$commentRespond.data('comment-id', comment.data.id).attr('data-comment-id', comment.data.id)
		$commentRespond.html tpl
		$commentRespond.addClass('with_form')
		$commentRespond.find('textarea.comment_textarea').attr('placeholder', 'Reply to Comment').focus()
		$commentRespond.find('a.cancel_reply').show()
		@scope.commentFormItem = item
		@scope.commentPostButton = "Reply"
		@compile($commentRespond.contents())(@scope)
		@timeout =>
			tinymce.execCommand('mceFocus', false, @scope.currentTinyMceEditor.id)
		, 800

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

	followUserFromComment: ($event, commentData) =>
		$event.preventDefault()
		if @scope.isSignedIn is false
			@requiresSignIn('follow this user', window.location.pathname)
		else
			@followUser commentData.userId, =>
				commentData.imFollowing = true
				@cookies.put('ok_to_flash', true)
				window.location.reload()
			, false, true

	unfollowUserFromComment: ($event, commentData) =>
		$event.preventDefault()
		@unfollowUser commentData.userId, =>
			commentData.imFollowing = false
			@cookies.put('ok_to_flash', true)
			window.location.reload()
		, true

	followUserFromFeed: ($event, user) =>
		$event.preventDefault()
		if @scope.isSignedIn is false
			@requiresSignIn('follow this user', window.location.pathname)
		else
			@followUser user.id, =>
				user.imFollowing = true
				@cookies.put('ok_to_flash', true)
				window.location.reload()
			, false, true

	unfollowUserFromFeed: ($event, user) =>
		$event.preventDefault()
		@unfollowUser user.id, =>
			user.imFollowing = false
			@cookies.put('ok_to_flash', true)
			window.location.reload()
		, true

	followUserFromCommentAuthError: ($event, item) =>
		$event.preventDefault()
		if @scope.isSignedIn is false
			@requiresSignIn('follow this user', window.location.pathname)
		else
			@followUserFromAuthError item, =>
				@showComments()

	followUserFromAuthError: ($event=null, item, canThenInteract=false) =>
		$event.preventDefault() if $event?
		if @scope.isSignedIn is false
			@requiresSignIn('follow this user', window.location.pathname)
		else
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
					@cookies.put('ok_to_flash', true)
					window.location.reload()
				item.actionAuthError = false
			, false, true

	showComments: ($event=null, item, startWriting=false) =>
		$event.preventDefault() if $event?
		item.actionAuthError = false
		if @scope.isSignedIn is false
			@requiresSignIn('view comments', window.location.pathname)
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

	renderCommentForm: (item, focusTextBox) =>
		tpl = angular.element("#commentForm").html()
		element = angular.element(".respond[data-share-id=#{item.share.id}]")
		element.html tpl
		element.addClass('with_form')
		@scope.commentFormItem = item
		@compile(element.contents())(@scope)
		if focusTextBox
			@timeout =>
				tinymce.execCommand('mceFocus', false, @scope.currentTinyMceEditor.id)
			, 800

	showCommentsSuccess: (item, focusTextBox, $event=null) =>
		item.share.showComments = true
		item.share.showAgrees = false
		item.share.showDisagrees = false
		if $event?
			$target = $($event.currentTarget)
			if $target.closest('.modal').length > 0
				@timeout =>
					$modalBody = $target.closest('.modal-body')
					pos = $modalBody.scrollTop()
					$modalBody.scrollTop pos + 160
				, 200
		@renderCommentForm(item, focusTextBox and (@scope.isSignedIn is true))

	showAllComments: ($event, item) =>
		$event.preventDefault()
		item.share.commentShowLimit = 0

	showAllReplies: ($event, comment) =>
		$event.preventDefault()
		comment.data.replyShowLimit = 0

	cancelReply: ($event, item) =>
		$event.preventDefault()
		@scope.commentFormItem = {}
		$commentsPane = $($event.target).closest('.comments_pane')
		@scope.replyingToComment =
			comment: {}
			parentComment: {}
			replyingToReply: false
		if angular.element(".respond[data-share-id=#{item.share.id}] form", $commentsPane).length
			$replyBox = angular.element(".respond[data-share-id=#{item.share.id}]", $commentsPane)
		else
			$replyBox = angular.element(".comment_respond[data-share-id=#{item.share.id}]", $commentsPane)
		$replyBox.find('a.cancel_reply', $replyBox).hide()
		$replyBox.data('comment-id', 0).attr('data-comment-id', 0)
		$replyBox.removeClass('with_form').html('')
		@renderCommentForm(item)

	postComment: ($event, post) =>
		$event.preventDefault()
		@scope.postingComment = true
		@scope.commentPostButton = "Posting..."
		$commentsPane = $($event.target).closest('.comments_pane')
		if angular.element(".respond[data-share-id=#{post.share.id}] form", $commentsPane).length
			$replyBox = angular.element(".respond[data-share-id=#{post.share.id}]", $commentsPane)
		else
			$replyBox = angular.element(".comment_respond[data-share-id=#{post.share.id}].with_form", $commentsPane)

		replyingToCommentId = Number($replyBox.data('comment-id'))
		replyingToUsername = if @scope.replyingToComment.replyingToReply then @scope.replyingToComment.comment.data.username else ''
		parentId = if 'id' of @scope.replyingToComment.parentComment then @scope.replyingToComment.parentComment.id else 0

		# update UI first
		now = new Date()
		timeActual = "#{now.getUTCFullYear()}-#{@padNumber(now.getUTCMonth()+1)}-#{@padNumber(now.getUTCDate())} #{now.getUTCHours()}:#{@padNumber(now.getUTCMinutes())}"
		monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
		timeHuman = "#{now.getUTCDate()} #{monthNames[now.getUTCMonth()]}"
		comment =
			id: null,
			path: @scope.myProfile.path,
			userId: @scope.myProfile.id,
			displayName: @scope.myProfile.displayName,
			username: @scope.myProfile.originalUsername,
			photo: @scope.myProfile.profilePhoto.image,
			body: @scope.commentForSubmission.value,
			timeActual: timeActual,
			timeHuman: timeHuman

		if replyingToCommentId is 0
			post.comments.unshift { data: comment }
		else
			angular.forEach post.comments, (rootComment) =>
				if rootComment is @scope.replyingToComment.comment
					unless 'children' of rootComment
						rootComment.children = []
					rootComment.children.unshift { data: comment }
				else
					okToContinue = true
					angular.forEach rootComment.children, (childComment, childIndex) =>
						if childComment is @scope.replyingToComment.comment && okToContinue
							rootComment.children.splice(childIndex+1, 0, { data: comment })
							okToContinue = false

		# then save to server
		new @Comment
			share_id: post.share.id
			body: @scope.commentForSubmission.value
			parent: parentId
			replying_to_username: replyingToUsername
		.create().then (responseComment) =>
			@timeout =>
				@scope.postingComment = false
				@scope.commentPostButton = "Post Comment"
				if responseComment.status is 'success'
					@cancelReply $event, post
					comment.id = responseComment.id
					@scope.commentForSubmission.value = ''
				else
					@alert responseComment.message
			, 300

	padNumber: (n) =>
		if n < 10 then '0' + n else n

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
			@requiresSignIn('interact with this post', window.location.pathname)


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
			@requiresSignIn('interact with this post', window.location.pathname)
		else if @rootScope.profileDeactivated
			@confirm "You must reactivate your profile in order to agree with this post", =>
				window.location.href = "/account-settings?reactivate=1"
			, null, "Error interacting with user", ['Cancel', 'Reactivate']
		else
			if !item.share.opinionsLoaded
				@loadOpinions item, =>
					@agreeWithPostSubmit(item)
			else
				@agreeWithPostSubmit(item)

	agreeWithPostSubmit: (item) =>
		action = if item.iAgreeWithPost is true then 'unagree' else 'agree'
		item.iAgreeWithPost = !item.iAgreeWithPost
		new @Opinion
			share_id: item.share.id
			action: action
		.create().then (opinion) =>
			if opinion.status is 'success'
				@rootScope.$broadcast 'opinion_on_feed_item', { action: action, share_id: item.share.id, user: opinion.user }
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
			@requiresSignIn('interact with this post', window.location.pathname)

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
			@requiresSignIn('interact with this post', window.location.pathname)
		else if @rootScope.profileDeactivated
			@confirm "You must reactivate your profile in order to disagree with this post", =>
				window.location.href = "/account-settings?reactivate=1"
			, null, "Error interacting with user", ['Cancel', 'Reactivate']
		else
			if !item.share.opinionsLoaded
				@loadOpinions item, =>
					@disagreeWithPostSubmit(item)
			else
				@disagreeWithPostSubmit(item)

	disagreeWithPostSubmit: (item) =>
		action = if item.iDisagreeWithPost is true then 'undisagree' else 'disagree'
		item.iDisagreeWithPost = !item.iDisagreeWithPost
		new @Opinion
			share_id: item.share.id
			action: action
		.create().then (opinion) =>
			if opinion.status is 'success'
				@rootScope.$broadcast 'opinion_on_feed_item', { action: action, share_id: item.share.id, user: opinion.user }
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
			callback.call(@) if callback?
			@timeout =>
				item.share.opinionsLoaded = true
			, 750

	followUserFromNoConnectionModal: (item, $event, canThenInteract=true) =>
		$event.preventDefault()
		if @scope.isSignedIn is false
			@requiresSignIn('follow this user', window.location.pathname)
		else
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
			@requiresSignIn('report this profile', window.location.pathname)
		else
			@openConcernReportModal('profile', profile)

	reportPost: ($event, item) =>
		$event.preventDefault()
		if @scope.isSignedIn is false
			@requiresSignIn('report this post', window.location.pathname)
		else
			item = item.share if _.contains(['commentAction', 'opinionAction', 'share', 'rating'], item.type)
			@openConcernReportModal('post', item)

	reportCommentAction: ($event=null, item) =>
		$event.preventDefault() if $event?
		if @scope.isSignedIn is false
			@requiresSignIn('report this comment', window.location.pathname)
		else
			@openConcernReportModal('commentAction', item)

	reportComment: ($event=null, item) =>
		$event.preventDefault() if $event?
		if @scope.isSignedIn is false
			@requiresSignIn('report this comment', window.location.pathname)
		else
			@openConcernReportModal('comment', item)

	openConcernReportModal: (type='post', resource) =>
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
			@requiresSignIn('mute a profile', window.location.pathname)
		else
			@http.post("/mutes", {id: userId, set_flash: true}).then (response) =>
				@cookies.put('ok_to_flash', true)
				window.location.reload()

	unmute: ($event, userId, username) =>
		$event.preventDefault()
		@http.delete("/mutes/#{userId}?set_flash=true").then (response) =>
			@cookies.put('ok_to_flash', true)
			window.location.reload()

	block: ($event=null, userId, username) =>
		$event.preventDefault() if $event?
		if @scope.isSignedIn is false
			@requiresSignIn('block a profile', window.location.pathname)
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
		@http.post("/blocks", {id: user.id, set_flash: true}).then (response) =>
			$("#confirmBlockModal").modal('hide')
			@cookies.put('ok_to_flash', true)
			window.location.reload()

	unblock: ($event, userId, username) =>
		$event.preventDefault()
		confirmMsg = "#{username} will be able to follow you and message you.  <a href='/help?section=blocking'>Read more</a> about what it means to block and unblock someone."
		@confirm confirmMsg, =>
			@http.delete("/blocks/#{userId}?set_flash=true").then (response) =>
				@cookies.put('ok_to_flash', true)
				window.location.reload()
		, null, "Unblock #{username}?", ["Cancel", "Unblock"]

	unfollow: ($event, userId, username) =>
		$event.preventDefault()
		@http.delete("/user_followings/#{userId}?set_flash=true").then (response) =>
			@cookies.put('ok_to_flash', true)
			window.location.reload()

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
		if @scope.thirdPartyUrl.value.length > 10
			if $event.keyCode is 13
				@scope.thirdPartyUrl.building = true
				@timeout =>
					@openThirdPartySharingPanel(@scope.thirdPartyUrl.value)
					@scope.thirdPartyUrl.building = false
				, 850

	openThirdPartySharingPanelFromPaste: ($event) =>
		@scope.thirdPartyUrl.building = true
		@timeout =>
			url = @scope.thirdPartyUrl.value
			startPos = url.indexOf('https://')
			startPos = url.indexOf('http://') if startPos < 0
			url = url.substring(startPos).replace(/(<([^>]+)>)/ig,"")
			@openThirdPartySharingPanel(url)
			@scope.thirdPartyUrl.building = false
		, 850

	openThirdPartySharingPanel: (url) =>
		if @rootScope.profileDeactivated
			@confirm "You will need to reactivate your profile to share or rate an article", =>
				window.location.href = "/account-settings?reactivate=1"
			, null, "Please reactivate profile", ['Cancel', 'Reactivate']
		else
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
				@scope.thirdPartyUrl =
					value: ''
					building: false

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

	showAllShareOpinionators: (share_id, decision) =>
		@http.get("/opinionators-of-share/#{share_id}?decision=#{decision.toLowerCase()}").then (response) =>
			@scope.opinionatorsOfShare = response.data
			@scope.opinionatorsOfShareDecision = decision
			tpl = $("#opinionatorsOfShare").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#opinionatorsOfShareModal").modal()

	showAllShareCommenters: (share_id) =>
		@http.get("/commenters-of-share/#{share_id}").then (response) =>
			@scope.commentersOfShare = response.data
			tpl = $("#commentersOnShare").html().trim()
			$content = @compile(tpl)(@scope)
			$('body').append $content
			$("#commentersOnShareModal").modal()

	interactionMute: ($event, share) =>
		$event.preventDefault()
		@http.post("/interaction-mute", {share_id: share.id}).then (response) =>
			if response.data.status is 'success'
				share.isInteractionMuted = true
				@flash "You have opted out of notifications for this post"
			else
				@alert response.data.message, "Error turning off notifications"

	interactionUnmute: ($event, share) =>
		$event.preventDefault()
		@http.delete("/interaction-mute/#{share.id}").then (response) =>
			if response.data.status is 'success'
				share.isInteractionMuted = false
				@flash "You have opted in to notifications for this post"
			else
				@alert response.data.message, "Error turning on notifications"

	updateAllWithOpinion: (data, shareId, action, user) =>
		angular.forEach data, (feedItem) =>
			if (feedItem.share?) and feedItem.share.id is shareId
				# console.log "another instance found of #{shareId}"
				@loadOpinions feedItem, =>
					switch action
						when 'agree'
							feedItem.iDisagreeWithPost = false
							feedItem.iAgreeWithPost = true
						when 'unagree'
							feedItem.iAgreeWithPost = false
						when 'disagree'
							feedItem.iAgreeWithPost = false
							feedItem.iDisagreeWithPost = true
						when 'undisagree'
							feedItem.iDisagreeWithPost = false

	formatExchangeList: (exchanges) =>
		sentence = ""
		total = exchanges.length
		angular.forEach exchanges, (exchange, i) =>
			sentence += "<a href='#{exchange.path}' class='text-green'>#{exchange.name}</a>"
			if total > 1
				if i is (total - 2)
					sentence += " and "
				else if i < (total - 2)
					sentence += ", "
		if total is 1
			sentence += " exchange"
		else
			sentence += " exchanges"
		sentence

	openTweetWindow: ($event, share, width=600, height=471) =>
		$event.preventDefault()
		articleUrl = share.article.url
		wellWritten = "#{share.ratings.wellWritten}/5"
		interesting = "#{share.ratings.validPoints}/5"
		agree = "#{share.ratings.agree}/5"
		ratingTweet = "I gave this the following rating on TheArticle: Well written #{wellWritten}, Interesting #{interesting}, Agree #{agree}. #{share.share.post}"
		url = "https://twitter.com/intent/tweet?url=#{articleUrl}&text=#{ratingTweet}"
		left = (screen.width/2)-(width/2)
		top = (screen.height/2)-(height/2)
		window.open(url, 'shareWindow', 'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no, width='+width+', height='+height+', top='+top+', left='+left)

TheArticle.ControllerModule.controller('FeedsController', TheArticle.Feeds)