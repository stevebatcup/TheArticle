class TheArticle.FlashNotice extends TheArticle.NGController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	]

	init: ->
		console.log 'say whao'
		@http.defaults.headers.common['Accept'] = 'application/json'
		@http.defaults.headers.common['Content-Type'] = 'application/json'

	actionFromFlash: (action) =>
		console.log "#{action} clicked"

TheArticle.ControllerModule.controller('FlashNoticeController', TheArticle.FlashNotice)