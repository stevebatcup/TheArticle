TheArticle.DirectiveModule.directive("fileread", [
	->
		return {
			scope: {
				fileread: '='
			}
			link: (scope, element, attributes) ->
				element.bind "change", (changeEvent) ->
					reader = new FileReader()
					reader.onload = (loadEvent) ->
						scope.$apply ->
							scope.fileread = loadEvent.target.result
					file = changeEvent.target.files[0]
					if file.type.match('image.*')
						reader.readAsDataURL file
					else
						scope.$apply ->
							scope.$parent.imageUploadError("Please make sure to upload an image file")
		}
])