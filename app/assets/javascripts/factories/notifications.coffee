TheArticle.FactoryModule.factory("Notification", ['RailsResource',
  (RailsResource) ->
    class Notification extends RailsResource
      @configure
        url: '/notifications'
        name: 'notification'
        interceptAuth: true
])