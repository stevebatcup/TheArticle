TheArticle.FactoryModule.factory("Feed", ['RailsResource',
  (RailsResource) ->
    class Feed extends RailsResource
      @configure
        url: '/my-home'
        name: 'feed'
        interceptAuth: true
])
.factory("Comment", ['RailsResource',
  (RailsResource) ->
    class Comment extends RailsResource
      @configure
        url: '/comments'
        name: 'comment'
        interceptAuth: true
])
.factory("Opinion", ['RailsResource',
  (RailsResource) ->
    class Opinion extends RailsResource
      @configure
        url: '/opinions'
        name: 'opinion'
        interceptAuth: true
])
.factory("Share", ['RailsResource',
  (RailsResource) ->
    class Share extends RailsResource
      @configure
        url: '/share'
        name: 'share'
        interceptAuth: true
])