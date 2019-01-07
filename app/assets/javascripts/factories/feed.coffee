TheArticle.FactoryModule.factory("Feed", ['RailsResource',
  (RailsResource) ->
    class Feed extends RailsResource
      @configure
        url: '/front-page'
        name: 'feed'
        interceptAuth: true
])
