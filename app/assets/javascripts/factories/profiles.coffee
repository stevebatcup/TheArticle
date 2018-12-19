TheArticle.FactoryModule.factory("Profile", ['RailsResource',
  (RailsResource) ->
    class Profile extends RailsResource
      @configure
        url: '/profile-by-id'
        name: 'profile'
        interceptAuth: true
])
.factory("MyProfile", ['RailsResource',
  (RailsResource) ->
    class MyProfile extends RailsResource
      @configure
        url: '/my-profile'
        name: 'profile'
        interceptAuth: true
])