TheArticle.FactoryModule.factory("EditorsPick", ['RailsResource',
  (RailsResource) ->
    class EditorsPick extends RailsResource
      @configure
        url: '/articles'
        name: 'editorspick'
        interceptAuth: true
])