TheArticle.DirectiveModule.directive("fileread", [
	->
		return {
			scope: {
				fileread: '='
			}
			link: (scope, element, attributes) ->
				element.bind "change", (changeEvent) ->
					reader = new FileReader()
					scope.$apply ->
						scope.$parent.denoteUploading(element)
					reader.onload = (loadEvent) ->
						scope.$apply ->
							scope.fileread = loadEvent.target.result
					file = changeEvent.target.files[0]
					if file.size >= 10000000
						scope.$apply ->
							scope.$parent.imageUploadError("Please make sure your image is less than 10MB", element)
					else
						if file.type.match('image.*')
							reader.readAsDataURL file
						else
							scope.$apply ->
								scope.$parent.imageUploadError("Please make sure to upload an image file", element)
		}
])