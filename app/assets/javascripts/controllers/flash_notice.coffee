class TheArticle.FlashNotice extends TheArticle.NGController

	@register window.App
	@$inject: [
	  '$scope'
	  '$rootScope'
	  '$http'
	]

	init: ->
		@http.defaults.headers.common['Accept'] = 'application/json'
		@http.defaults.headers.common['Content-Type'] = 'application/json'

	actionFromFlash: (action) =>

TheArticle.ControllerModule.controller('FlashNoticeController', TheArticle.FlashNotice)