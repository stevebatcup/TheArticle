class TheArticle.User extends TheArticle.AdminPageController

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
		@setDefaultHttpHeaders()
		@setCsrfTokenHeaders()
		@watch()

	watch: =>
		@scope.$watch 'userForBox.fullDetailsLoaded', (oldVal, newVal) =>
			if newVal isnt oldVal
				@scope.availableAuthors = []
				@getAvailableAuthors()

		@scope.$watch 'userForBox.profilePhoto.src', (newVal, oldVal) =>
			if (oldVal isnt newVal) and newVal.length > 0
				@showProfilePhotoCropper 'profilePhoto_holder', 'profile', @scope.userForBox.profilePhoto.width, @scope.userForBox.profilePhoto.height

		@scope.$watch 'userForBox.coverPhoto.src', (newVal, oldVal) =>
			if (oldVal isnt newVal) and newVal.length > 0
				@showProfilePhotoCropper 'coverPhoto_holder', 'cover', @scope.userForBox.coverPhoto.width, @scope.userForBox.coverPhoto.height


	addToBlackList: ($event) =>
		$event.preventDefault()
		q = "Are you sure you wish to delete #{@scope.userForBox.name}'s account and add them to the blacklist?"
		@confirm q, @addToBlackListConfirm, null, "Sure?", ["No", "Yes, delete and blacklist"]

	addToBlackListConfirm: =>
		@scope.userForBox.blacklisted = true
		@http.get("/admin/add_user_to_blacklist?user_id=#{@scope.userForBox.id}").then (response) =>
			if response.data.status isnt 'success'
				@scope.userForBox.blacklisted = false

	addToWatchList: ($event) =>
		@scope.userForBox.watchlisted = true
		$event.preventDefault()
		@http.get("/admin/add_user_to_watchlist?user_id=#{@scope.userForBox.id}").then (response) =>
			if response.data.status isnt 'success'
				@scope.userForBox.watchlisted = false

	deactivate: ($event) =>
		$event.preventDefault()
		q = "Are you sure you wish to deactivate #{@scope.userForBox.name}'s account?"
		@confirm q, @deactivateConfirm, null, "Sure?", ["No", "Yes, deactivate"]

	deactivateConfirm: =>
		originalStatus = @scope.userForBox.status
		@scope.userForBox.status = 'deactivated'
		@scope.userForBox.deactivated = true
		@http.get("/admin/deactivate_user?user_id=#{@scope.userForBox.id}").then (response) =>
			if response.data.status isnt 'success'
				@scope.userForBox.status = originalStatus
				@scope.userForBox.deactivated = false

	reactivate: ($event) =>
		originalStatus = @scope.userForBox.status
		@scope.userForBox.status = 'active'
		@scope.userForBox.deactivated = false
		$event.preventDefault()
		@http.get("/admin/reactivate_user?user_id=#{@scope.userForBox.id}").then (response) =>
			if response.data.status isnt 'success'
				@scope.userForBox.status = originalStatus
				@scope.userForBox.deactivated = true

	delete: ($event) =>
		$event.preventDefault()
		q = "Are you sure you wish to delete #{@scope.userForBox.name}'s account?"
		@confirm q, @deleteConfirm, null, "Sure?", ["No", "Yes, delete"]

	deleteConfirm: =>
		originalStatus = @scope.userForBox.status
		@scope.userForBox.status = 'deleted'
		@scope.userForBox.deleted = true
		@http.delete("/admin/delete_user?user_id=#{@scope.userForBox.id}").then (response) =>
			if response.data.status isnt 'success'
				@scope.userForBox.status = originalStatus
				@scope.userForBox.deleted = false

	getAvailableAuthors: =>
		@http.get("/admin/available_authors_for_user/#{@scope.userForBox.id}").then (response) =>
			@scope.availableAuthors = response.data.authors
			if 'authorId' of @scope.userForBox
				angular.forEach @scope.availableAuthors, (author) =>
					if Number(author.id) is Number(@scope.userForBox.authorId)
						@scope.userForBox.author = author

	updateAuthor: =>
		data =
			user_id: @scope.userForBox.id
			author_id: if @scope.userForBox.author then @scope.userForBox.author.id else null
		@http.post("/admin/set_author_for_user", data)

	updateGenuineVerified: =>
		data =
			user_id: @scope.userForBox.id
			genuine_verified: if @scope.userForBox.genuineVerified then 1 else 0
		@http.post("/admin/set_genuine_verified_for_user", data)

	removeAdditionalEmail: (id, $event) =>
		$event.preventDefault()
		@http.delete("/admin/delete_additional_email?user_id=#{@scope.userForBox.id}&email_id=#{id}").then (response) =>
			if response.data.status is 'success'
				@scope.userForBox.additionalEmails = _.reject @scope.userForBox.additionalEmails, (item) =>
					item.id is id

	addAdditionalEmail: =>
		@scope.userForBox.addingAdditionalEmail.css = ''
		@scope.userForBox.addingAdditionalEmail.message = ''
		if !@scope.userForBox.addingAdditionalEmail.text or @scope.userForBox.addingAdditionalEmail.text.length is 0
			@scope.userForBox.addingAdditionalEmail.css = 'text-danger'
			@scope.userForBox.addingAdditionalEmail.message = 'Enter a valid email address'
		else
			data =
				user_id: @scope.userForBox.id
				email: @scope.userForBox.addingAdditionalEmail.text
			@http.post("/admin/add_additional_email", data).then (response) =>
				@scope.userForBox.addingAdditionalEmail.text = ''
				@scope.userForBox.addingAdditionalEmail.css = 'text-green'
				@scope.userForBox.addingAdditionalEmail.message = 'Email address successfully added'
				@scope.userForBox.additionalEmails.push { id: response.data.id, text: response.data.text }
				@timeout =>
					@scope.userForBox.addingAdditionalEmailStatus = ''
				, 3000

	removeLinkedAccount: (id, $event) =>
		$event.preventDefault()
		@http.delete("/admin/delete_linked_account?user_id=#{@scope.userForBox.id}&linked_account_id=#{id}").then (response) =>
			if response.data.status is 'success'
				@scope.userForBox.linkedAccounts = _.reject @scope.userForBox.linkedAccounts, (item) =>
					item.id is id

	addLinkedAccount: =>
		@scope.userForBox.addingLinkedAccount.css = ''
		@scope.userForBox.addingLinkedAccount.message = ''
		if @scope.userForBox.addingLinkedAccount.id.length is 0 || isNaN(@scope.userForBox.addingLinkedAccount.id)
			@scope.userForBox.addingLinkedAccount.css = 'text-danger'
			@scope.userForBox.addingLinkedAccount.message = 'Enter a valid account ID'
		else
			data =
				user_id: @scope.userForBox.id
				linked_account: @scope.userForBox.addingLinkedAccount.id
			@http.post("/admin/add_linked_account", data).then (response) =>
				if response.data.status is 'success'
					@scope.userForBox.addingLinkedAccount.id = ''
					@scope.userForBox.addingLinkedAccount.css = 'text-green'
					@scope.userForBox.addingLinkedAccount.message = 'Account successfully linked'
					@scope.userForBox.linkedAccounts.push { id: response.data.id, displayName: response.data.displayName }
					@timeout =>
						@scope.userForBox.addingLinkedAccountStatus = ''
					, 3000
				else
					@scope.userForBox.addingLinkedAccount.css = 'text-danger'
					@scope.userForBox.addingLinkedAccount.message = response.data.message

	updateBio: =>
		@scope.userForBox.bioUpdating = true
		data =
			user_id: @scope.userForBox.id
			bio: @scope.userForBox.bio
			send_alert: @scope.userForBox.alertBioUpdated
		@http.post("/admin/update-user-bio", data).then (response) =>
			if response.data.status is 'error'
				alert response.data.message, "Whoops!"
				@scope.userForBox.bioUpdating = false
			else if response.data.status is 'success'
				@timeout =>
					@scope.userForBox.bioUpdated = true
					@scope.userForBox.bioUpdating = false
					@timeout =>
						@scope.userForBox.bioUpdated = false
					, 5000
				, 750

	sendEmail: =>
		@scope.userForBox.newEmail.error = false
		if @scope.userForBox.newEmail.subject.length is 0 || @scope.userForBox.newEmail.message.length is 0
			@scope.userForBox.newEmail.error = 'Please enter both a subject and a message'
		else
			@scope.userForBox.newEmail.sending = true
			data =
				user_id: @scope.userForBox.id
				subject: @scope.userForBox.newEmail.subject
				message: @scope.userForBox.newEmail.message
			@http.post("/admin/send-email", data).then (response) =>
				if response.data.status is 'error'
					@alert response.data.message, "Whoops!"
					@scope.userForBox.newEmail.sending = false
				else if response.data.status is 'success'
					@timeout =>
						@scope.userForBox.newEmail.sent = true
						@scope.userForBox.newEmail.subject = ''
						@scope.userForBox.newEmail.message = ''
						@scope.userForBox.newEmail.sending = false
						@timeout =>
							@scope.userForBox.newEmail.sent = false
						, 5000
					, 750

	removePhoto: ($event, photoType) =>
		$event.preventDefault()
		key = "#{photoType}Photo"
		if @scope.userForBox[key].removing is false
			@scope.userForBox[key].removing = true
			@timeout =>
				@http.delete("/admin/remove_photo/#{photoType}/#{@scope.userForBox.id}").then (response) =>
					if response.data.status is 'success'
						@scope.userForBox[key].originalSrc = response.data.src
						@scope.userForBox.profilePhoto.isDefault = true if photoType is 'profile'
						@scope.userForBox[key].removing = false
					else
						@alert response.data.message, "Error..."
			, 900

	uploadPhoto: ($event, photoType) =>
		$event.preventDefault()
		@scope.userForBox["#{photoType}Photo"].uploading = true
		@showPhotoModal(photoType)
		@timeout =>
			$("##{photoType}Photo_uploader").focus().trigger('click')
		, 250

	denoteUploading: (element) =>
		photoType = $(element).data('type')
		@scope.userForBox["#{photoType}Photo"].uploading = true
		@scope.userForBox["#{photoType}Photo"].errors = ""

	imageUploadError: (error, element) =>
		photoType = $(element).data('type')
		@scope.userForBox["#{photoType}Photo"].errors = error
		@timeout =>
			@scope.userForBox["#{photoType}Photo"].uploading = false
		, 300

	downloadPhoto: ($event, photoType) =>
		$event.preventDefault()

	showPhotoModal: (photoType) =>
		photoKey = "#{photoType}Photo"
		holderId = "#{photoKey}_holder"
		tpl = $("#edit_#{photoKey}").html().trim()
		$content = @compile(tpl)(@scope)
		$('body').append $content
		$("#edit#{photoKey}Modal").modal()

	showProfilePhotoCropper: (holderId, photoType, width, height) =>
		@scope.userForBox["#{photoType}Photo"].errors = ""
		@timeout =>
			@scope.userForBox["#{photoType}Photo"].uploading = false
		, 500
		$element = document.getElementById(holderId)
		@scope.userForBox.photoCrop.cropper = new Cropper $element,
			checkOrientation: true
			checkCrossOrigin: true
			minCropBoxWidth: width
			minCropBoxHeight: height
			center: true
			cropBoxResizable: false
			viewMode: if photoType is 'cover' then 3 else 1
			dragMode: 'none'
		@timeout =>
			containerData = @scope.userForBox.photoCrop.cropper.getContainerData()
			@scope.userForBox.photoCrop.cropper.setCropBoxData
				width: width
				height: height
				left: (containerData.width / 2) - (width / 2)
				top: (containerData.height / 2) - (height / 2)
			if photoType is 'coverPhoto'
				@scope.userForBox.photoCrop.cropper.zoomTo .5,
					x: containerData.width / 2
					y: containerData.height / 2
		, 350

	rotatePhoto: (deg) =>
		@scope.userForBox.photoCrop.cropper.rotate(deg, null)
		@scope.userForBox.photoCrop.cropper.crop()

	zoomPhoto: (factor) =>
		@scope.userForBox.photoCrop.cropper.zoom(factor, null)

	movePhoto: (x, y) =>
		@scope.userForBox.photoCrop.cropper.move(x, y)

	scalePhotoX: ($event) =>
		factor = @scope.userForBox.photoCrop.scaleX
		@scope.userForBox.photoCrop.cropper.scaleX(-factor)
		@scope.userForBox.photoCrop.scaleX = -factor

	scalePhotoY: ($event) =>
		factor = @scope.userForBox.photoCrop.scaleY
		@scope.userForBox.photoCrop.cropper.scaleY(-factor)
		@scope.userForBox.photoCrop.scaleY = -factor

	resetPhoto: =>
		@scope.userForBox.photoCrop.cropper.reset()

	cropPhoto: =>
		@scope.userForBox.photoCrop.cropper.crop()

	saveCroppedPhoto: ($event, photoType) =>
		$event.preventDefault()
		@scope.userForBox.photoCrop.cropper.crop()
		@scope.userForBox[photoType].uploading = true
		settings =
			width: (@scope.userForBox[photoType].width * 2),
			minWidth: (@scope.userForBox[photoType].width * 2),
			height: (@scope.userForBox[photoType].height * 2),
			minHeight: (@scope.userForBox[photoType].height * 2),
			imageSmoothingEnabled: true,
			imageSmoothingQuality: 'high'
		@scope.userForBox.photoCrop.cropper.getCroppedCanvas(settings).toBlob (blob) =>
			formData = new FormData()
			formData.append('photo', blob)
			formData.append('mode', photoType)
			formData.append('user_id', @scope.userForBox.id)
			$.ajax '/admin/update-user-photo',
				method: "PUT"
				data: formData
				processData: false
				contentType: false
				success: (response) =>
					if response.status is 'error'
						@savePhotoError response.message, photoType
					else
						@timeout =>
							@scope.userForBox[photoType].originalSrc = @scope.userForBox.photoCrop.cropper.getCroppedCanvas().toDataURL('image/jpeg')
							@scope.userForBox[photoType].uploading = false
							@scope.userForBox.profilePhoto.isDefault = false if photoType is 'profilePhoto'
							@cancelEditPhoto(photoType)
							@confirm "Would you also like to send an email to this member to alert them of this newly uploaded photo?", =>
								@sendNewPhotoAlertEmail(photoType)
							, null, "Send email alert?", ["No", "Yes, send email"]
						, 750
				error: (error) =>
					@savePhotoError error.statusText, photoType

	sendNewPhotoAlertEmail: (photoType) =>
		type = if photoType == 'profilePhoto' then 'profile' else 'cover'
		@http.get("/admin/send-new-photo-alert-email/#{type}/#{@scope.userForBox.id}")

	savePhotoError: (msg, photoType) =>
		console.log msg
		@scope.$apply =>
			@scope.userForBox[photoType].uploading = false
			@scope.userForBox[photoType].errors = "Error uploading new photo: #{msg}"

	cancelEditPhoto: (photoType) =>
		@scope.userForBox[photoType].source = ''
		@scope.userForBox.photoCrop.cropper.destroy()
		$("#edit#{photoType}Modal").modal('hide')
		$("#{photoType}_holder").attr("src", "")
		$("##{photoType}_uploader").val('')


TheArticle.ControllerModule.controller('UserController', TheArticle.User)