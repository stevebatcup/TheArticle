class TheArticle.Feeds extends TheArticle.NGController

	@register window.App
	@$inject: [
	  '$scope'
	  '$timeout'
	  'Comment'
	  'Opinion'
	]

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
		@scope.replyingToComment =
			comment: comment
			parentComment: parentComment.data
			replyingToReply: replyingToReply
		$commentBox = $("[data-comment-id=#{comment.data.id}]")
		$replyBox = $commentBox.closest('.comments_pane').find('.respond')
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

	showComments: ($event, item, startWriting=false) =>
		$event.preventDefault()
		if @scope.isSignedIn is false
			@requiresSignIn('view comments')
		else if (item.canInteract != 'yes') and (startWriting is true)
			item.actionAuthError = "You need to be connected to #{item.user.displayName} to interact with this post"
		else
			if !item.share.commentsLoaded
				@Comment.query({share_id: item.share.id}).then (comments) =>
						item.comments = comments
						@showCommentsSuccess(item, startWriting, $event)
						@timeout =>
							item.share.commentsLoaded = true
						, 750
			else
				@showCommentsSuccess(item, startWriting, $event)

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
		@scope.replyingToComment =
			comment: {}
			parentComment: {}
			replyingToReply: false
		$replyBox = $(".respond[data-share-id=#{shareId}]")
		$replyBox.find('a.cancel_reply', $replyBox).hide()
		$replyBox.find('textarea').attr('placeholder', 'Add your Comment')
		$replyBox.data('comment-id', 0).attr('data-comment-id', 0)
		$replyBox.detach().prependTo('.comments_pane')

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

	showAgrees: ($event, item) =>
		$event.preventDefault()
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

	agreeWithPost: ($event, item) =>
		$event.preventDefault()
		if @scope.isSignedIn is false
			@requiresSignIn('interact with this post')
		else if item.canInteract != 'yes'
			item.actionAuthError = "You need to be connected to #{item.user.displayName} to interact with this post"
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

	showDisagrees: ($event, item) =>
		$event.preventDefault()
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

	disagreeWithPost: ($event, item) =>
		$event.preventDefault()
		if @scope.isSignedIn is false
			@requiresSignIn('interact with this post')
		else if item.canInteract != 'yes'
			item.actionAuthError = "You need to be connected to #{item.user.displayName} to interact with this post"
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


TheArticle.ControllerModule.controller('FeedsController', TheArticle.Feeds)