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
.factory("LandingPageArticle", ['RailsResource',
  (RailsResource) ->
    class LandingPageArticle extends RailsResource
      @configure
        url: '/articles'
        name: 'landingPagearticle'
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
.factory("ArticleRating", ['RailsResource',
  (RailsResource) ->
    class ArticleRating extends RailsResource
      @configure
        url: '/ratings-history'
        name: 'articlerating'
        interceptAuth: true
])