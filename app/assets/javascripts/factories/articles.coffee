TheArticle.FactoryModule.factory("EditorsPick", ['RailsResource',
  (RailsResource) ->
    class EditorsPick extends RailsResource
      @configure
        url: '/articles'
        name: 'editorspick'
        interceptAuth: true
])
.factory("SponsoredPick", ['RailsResource',
  (RailsResource) ->
    class SponsoredPick extends RailsResource
      @configure
        url: '/articles'
        name: 'sponsoredpick'
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
.factory("ContributorArticle", ['RailsResource',
  (RailsResource) ->
    class ContributorArticle extends RailsResource
      @configure
        url: '/articles'
        name: 'contributorarticle'
        interceptAuth: true
])