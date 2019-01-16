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
.factory("FollowGroup", ['RailsResource',
  (RailsResource) ->
    class FollowGroup extends RailsResource
      @configure
        url: '/follow-groups'
        name: 'follow_group'
        interceptAuth: true
])