TheArticle.FactoryModule.factory("Feed", ['RailsResource',
  (RailsResource) ->
    class Feed extends RailsResource
      @configure
        url: '/front-page'
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