TheArticle.DirectiveModule.directive("fileread", [
	->
		return {
			scope: {
				fileread: "="
			}
			link: (scope, element, attributes) ->
				element.bind "change", (changeEvent) ->
					reader = new FileReader()
					reader.onload = (loadEvent) ->
						scope.$apply ->
							scope.fileread = loadEvent.target.result
					reader.readAsDataURL changeEvent.target.files[0]
		}
])