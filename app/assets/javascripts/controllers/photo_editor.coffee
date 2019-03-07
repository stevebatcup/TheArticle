class TheArticle.PhotoEditor extends TheArticle.PageController

	rotatePhoto: (deg) =>
		@scope.photoCrop.cropper.rotate(deg, null)
		@scope.photoCrop.cropper.crop()

	zoomPhoto: (factor) =>
		@scope.photoCrop.cropper.zoom(factor, null)

	movePhoto: (x, y) =>
		@scope.photoCrop.cropper.move(x, y)

	scalePhotoX: ($event) =>
		factor = @scope.photoCrop.scaleX
		@scope.photoCrop.cropper.scaleX(-factor)
		@scope.photoCrop.scaleX = -factor

	scalePhotoY: ($event) =>
		factor = @scope.photoCrop.scaleY
		@scope.photoCrop.cropper.scaleY(-factor)
		@scope.photoCrop.scaleY = -factor

	resetPhoto: =>
		@scope.photoCrop.cropper.reset()

	cropPhoto: =>
		@scope.photoCrop.cropper.crop()


TheArticle.ControllerModule.controller('PhotoEditorController', TheArticle.PhotoEditor)