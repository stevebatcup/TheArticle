TheArticle.FactoryModule.factory("ConcernReport", ['RailsResource',
  (RailsResource) ->
    class ConcernReport extends RailsResource
      @configure
        url: '/concern-reports'
        name: 'concernReport'
        interceptAuth: true
])
