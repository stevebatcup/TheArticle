TheArticle.FactoryModule.factory("Profile", ['RailsResource',
  (RailsResource) ->
    class Profile extends RailsResource
      @configure
        url: '/profile'
        name: 'profile'
        interceptAuth: true
])