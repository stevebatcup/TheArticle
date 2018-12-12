TheArticle.FactoryModule.factory("EditorsPick", ['RailsResource',
  (RailsResource) ->
    class EditorsPick extends RailsResource
      @configure
        url: '/articles'
        name: 'editorspick'
        interceptAuth: true
])
.factory("ExchangeArticle", ['RailsResource',
  (RailsResource) ->
    class ExchangeArticle extends RailsResource
      @configure
        url: '/articles'
        name: 'exchangearticle'
        interceptAuth: true
])